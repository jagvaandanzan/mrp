class SaleTax < ApplicationRecord
  belongs_to :product_sale, optional: true
  belongs_to :direct_sale, optional: true

  before_validation :check_register
  after_validation :send_tax
  before_save :set_price

  enum tax_type: {individual: 0, organization: 1}

  validates :tax_type, presence: true

  attr_accessor :user

  with_options :if => Proc.new {|m| m.individual? && !m.phone.present?} do
    validates :email, presence: true
  end

  with_options :if => Proc.new {|m| m.individual? && !m.email.present?} do
    validates :phone, presence: true
  end

  with_options :if => Proc.new {|m| m.organization?} do
    validates :email, presence: true
    validates :register, presence: true
  end

  scope :order_desc, ->() {
    order(created_at: :desc)
  }

  scope :search, ->(tax_type, phone, email, register) {
    items = order_desc
    items = items.where(tax_type: tax_types[tax_type]) if tax_type.present?
    items = items.where(phone: phone) if phone.present?
    items = items.where(email: email) if email.present?
    items = items.where(register: register) if register.present?
    items
  }

  private

  def set_price
    self.price = product_sale.present? ? product_sale.bought_price : direct_sale.product_price
  end

  def check_register
    if tax_type.present? && organization?
      response = ApplicationController.helpers.api_send("#{ENV['DOMAIN_NAME']}/api/v1/notifications/organization", 'post', {register: register}.to_json)
      json = JSON.parse(response.body)
      unless !!json["success"]
        self.errors.add(:register, ": байгууллага олдсонгүй!")
      end
    end
  end

  def send_tax
    # response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/savebanktrans", 'post', param.to_json)
    param = API::V1::Entities::ProductSaleItem.represent product_sale.product_sale_items
    response = ApplicationController.helpers.api_send("#{ENV['DOMAIN_NAME']}/api/v1/notifications/tax", 'post', param.to_json)
    json = JSON.parse(response.body)

    if response.code.to_i == 201
      code = json['code']
      number = json['number']
      qr = json['qr']
      if email.present?
        user.send_tax(email, price, code, number, qr)
      else
        message = "[Market.mn] dun: #{price}, suglaanii code: #{code.gsub(" ", '')}"
        response = ApplicationController.helpers.api_send("http://web2sms.skytel.mn/apiSend?token=#{ENV['SKYTEL_SMS']}&sendto=#{phone}&message=#{message}", 'post')

        if response.code.to_i == 200
          json = JSON.parse(response.body)
          if json["status"] != 1
            if email.present?
              self.errors.add(:email, "-рүү илгээж чадсангүй!")
            else
              self.errors.add(:phone, ":-руу илгээж чадсангүй!")
            end
          end
        end
      end
    else
      if email.present?
        self.errors.add(:email, "-рүү илгээж чадсангүй!")
      else
        self.errors.add(:phone, ":-руу илгээж чадсангүй!")
      end
    end
  end
end