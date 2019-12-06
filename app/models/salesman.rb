# frozen_string_literal: true
class Salesman < ActiveRecord::Base
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :rememberable, :registerable,
  devise :database_authenticatable, :recoverable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  has_many :salesman_travels

  after_destroy :destroy_email
  before_validation :generate_password, on: :create
  before_create :set_pin_code

  enum gender: {male: 0, female: 1}

  validates :surname, :name, :phone, :register, presence: true, length: {maximum: 255}
  validates :gender, :email, presence: true

  scope :search, ->(search_id, search_name, search_phone) {
    items = created_at_desc
    items = items.where('id = ?', search_id) if search_id.present?
    items = items.where('name LIKE :value OR surname LIKE :value', value: "%#{search_name}%") if search_name.present?
    items = items.where('phone = ?', search_phone) if search_phone.present?
    items
  }

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  def send_first_password_instructions
    send_devise_notification(:first_password_instructions, password, subject: 'Нэвтрэх нууц үгийн мэдээлэл', to: email)
  end

  def id_number
    id.to_s.rjust(3, '0')
  end

  protected

  def devise_mailer
    SalesmanMailer
  end

  private

  def set_pin_code
    self.pin_code = 4.times.map {rand(10)}.join
  end

  def generate_password
    if password.blank?
      self.allow_password_change = true
      self.password = Devise.friendly_token(6)
    end
  end

  def destroy_email
    email_bits = email.split('@')
    update!(email: "#{email_bits[0]}_#{Time.zone.now.to_i}@#{email_bits[1]}")
  end

end
