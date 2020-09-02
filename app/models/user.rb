class User < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  belongs_to :user_position
  has_many :user_permission_rels, dependent: :destroy

  accepts_nested_attributes_for :user_permission_rels, reject_if: :all_blank, allow_destroy: true

  after_destroy :destroy_email
  before_validation :generate_password, on: :create
  after_validation :remove_unnecessary_error_messages

  enum gender: {male: 0, female: 1}

  validates :surname, :name, :phone, presence: true, length: {maximum: 255}
  validates :gender, :user_position_id, :user_permission_rels, presence: true
  validates :email, uniqueness: {conditions: -> { with_deleted }}
  validate :permission_rel_should_be_uniq

  scope :search, ->(search_name, search_email, search_phone) {
    items = created_at_desc
    items = items.where('name LIKE :value OR surname LIKE :value', value: "%#{search_name}%") if search_name.present?
    items = items.where('email = ?', search_email) if search_email.present?
    items = items.where('phone = ?', search_phone) if search_phone.present?
    items
  }

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  def send_first_password_instructions
    send_devise_notification(:first_password_instructions, password, subject: 'Нэвтрэх нууц үгийн мэдээлэл', to: email)
  end

  def reset_password_app(email, url_token)
    send_devise_notification(:reset_password_app, email, url_token, subject: '[Market.mn] Нууц үг солих хүсэлт', to: email)
  end

  def user_name
    "#{surname} #{name}"
  end

  def is_admin?
    user_position_id == 1
  end

  def is_stockkeeper?
    user_position_id == 2
  end

  def is_user?
    user_position_id == 3
  end

  def push_options(type, p_title, content)
    {
        data: {type: type, id: id},
        notification: {
            title: p_title,
            body: content,
            sound: "default"},
        priority: 'high',
    }
  end

  protected

  def devise_mailer
    UserMailer
  end

  private

  def generate_password
    if password.blank?
      self.password_is_reset = true if self.password_is_reset != false
      self.password = Devise.friendly_token(6)
    end
  end

  def destroy_email
    email_bits = email.split('@')
    update!(email: "#{email_bits[0]}_#{Time.zone.now.to_i}@#{email_bits[1]}")
  end

  def remove_unnecessary_error_messages
    errors.messages.each { |key, val| val.uniq! }
  end

  def permission_rel_should_be_uniq
    uniq_by_permission_rel = user_permission_rels.uniq(&:user_permission_id)

    if user_permission_rels.length != uniq_by_permission_rel.length
      self.errors.add(:user_permission_rels, :taken)
    end
  end
end
