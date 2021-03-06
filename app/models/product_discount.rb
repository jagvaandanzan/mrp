class ProductDiscount < ApplicationRecord
  belongs_to :product
  belongs_to :user

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type, :real_price
  before_save :set_percent

  validates :start_date, :end_date, :price, presence: true

  scope :order_date, ->() {
    order(end_date: :desc)
  }

  scope :by_available, ->() {
    where("start_date <= ?", Time.current.beginning_of_day)
        .where("end_date >= ?", Time.current.beginning_of_day)
        .order(:start_date)
  }

  def start_date
    self[:start_date].strftime('%F') if self[:start_date].present?
  end

  def end_date
    self[:end_date].strftime('%F') if self[:end_date].present?
  end

  private

  def set_percent
    if real_price.present?
      self.percent = 100 - ((price.to_f * 100) / real_price.to_f)
    end
  end

  def sync_web(method)
    if product.is_sync
      self.method_type = method
      url = "product/discount"

      if method == 'delete'
        params = nil
        url += "/" + id.to_s
      else

        params = self.to_json(only: [:id, :product_id, :price, :percent, :start_date, :end_date], :methods => [:method_type])
      end

      ApplicationController.helpers.api_request(url, method, params)
    end
  end
end
