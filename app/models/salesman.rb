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

  validates :surname, :name, :register, presence: true, length: {maximum: 255}
  validates :gender, :email, :phone, :avatar, :price, :price_at, :distribution, presence: true
  validates :pin_code, length: {is: 4}, on: :update
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
  has_attached_file :avatar, :path => ":rails_root/public/salesman/:id_partition/:style.:extension", styles: {original: "800x800>", tumb: "200x200>"}, :url => '/salesman/:id_partition/:style.:extension'
  validates_attachment :avatar,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  scope :search, ->(search_id, search_name, search_phone) {
    items = order_name
    items = items.where('id = ?', search_id) if search_id.present?
    items = items.where('name LIKE :value OR surname LIKE :value', value: "%#{search_name}%") if search_name.present?
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
    send_devise_notification(:first_password_instructions, password, subject: '[Market.mn] Нэвтрэх нууц үгийн мэдээлэл', to: email)
  end

  def reset_password_instructions(email, url_token)
    send_devise_notification(:reset_password_instructions, email, url_token, subject: '[Market.mn] Нууц үг солих хүсэлт', to: email)
  end


  def id_number
    id.to_s.rjust(3, '0')
  end

  def full_name
    "#{id_number} - #{name}"
  end

  def avatar_tumb
    avatar.url(:tumb)
  end

  def s_name
    s = ""
    s = "#{surname[0]}." if surname.present?
    "#{s}#{name}"
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

  def update_distribution(date, distributions)

    if Time.current.beginning_of_day == date.beginning_of_day

    end
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
