class AdminUser < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable,:registerable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :admin_permission

  after_destroy :destroy_email
  before_validation :generate_password, on: :create

  validates :email, uniqueness: {conditions: -> {with_deleted}}
  validates :admin_permission_id, presence: true
  after_validation :remove_unnecessary_error_messages
  validates :password, format: {with: /\A[a-z0-9]+\z/i}, on: :create

  def send_first_password_instructions
    send_devise_notification(:first_password_instructions, password, subject: "Нэвтрэх нууц үгийн мэдээлэл", to: email)
  end

  def is_admin
    admin_permission_id == 1
  end

  protected

  def devise_mailer
    AdminUserMailer
  end

  private

  def generate_password
    if password.blank?
      self.password_is_reset = true
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
