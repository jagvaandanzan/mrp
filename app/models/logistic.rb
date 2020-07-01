class Logistic < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable,:registerable, and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  after_destroy :destroy_email
  before_validation :generate_password, on: :create
  after_validation :remove_unnecessary_error_messages

  enum gender: {male: 0, female: 1}

  validates :surname, :name, :phone, presence: true, length: {maximum: 255}
  validates :gender, presence: true
  validates :email, uniqueness: {conditions: -> {with_deleted}}

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

  scope :order_name, -> {
    order(:name)
  }

  def send_first_password_instructions
    send_devise_notification(:first_password_instructions, password, subject: 'Нэвтрэх нууц үгийн мэдээлэл', to: email)
  end

  protected

  def devise_mailer
    LogisticMailer
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
    errors.messages.each {|key, val| val.uniq!}
  end
end
