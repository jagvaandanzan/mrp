class SalesmanTravel < ApplicationRecord
  belongs_to :salesman
  belongs_to :user, optional: true

  has_many :salesman_travel_routes, -> {with_deleted.order(:queue)}
  has_many :product_sales
  has_many :product_sale_items, through: :product_sales
  has_one :salesman_travel_sign, dependent: :destroy
  has_many :product_warehouse_locs, -> {order(:queue)}, dependent: :destroy

  scope :open_delivery, ->(salesman_id) {
    where(salesman_id: salesman_id)
        .where("delivered_at IS ?", nil)
        .order(:created_at)
  }

  scope :travels, ->(salesman_id, date) {
    where(salesman_id: salesman_id)
        .where('delivery_at >= ?', date)
        .where('delivery_at < ?', date + 1.days)
        .order(:delivery_at)
        .order(created_at: :desc)
  }

  scope :by_id_and_salesman, ->(id, salesman_id) {
    where(salesman_id: salesman_id)
        .where(id: id)
  }
  scope :by_signed, ->() {
    where("load_at IS NOT ?", nil)
        .where("sign_at IS NOT ?", nil)
  }

  scope :by_load_at, ->(loaded, date) {
    if loaded
      items = where("load_at IS#{loaded ? " NOT" : ""} ?", nil)
      items = items.where('load_at >= ?', date)
                  .where('load_at < ?', date + 1.days) if date.present?
      items
    else
      where("load_at IS ?", nil)
    end
  }

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  scope :by_date, ->(date) {
    where('created_at >= ?', date)
        .where('created_at < ?', date + 1.days) if date.present?
  }

  def id_number
    id.to_s.rjust(5, '0')
  end

  def route_count
    salesman_travel_routes.count
  end

  def load_count
    product_warehouse_locs.by_load_at(true).count
  end

  def salesman_at_count
    product_warehouse_locs.by_salesman_at(true).count
  end

  def load_sum
    product_warehouse_locs.count
  end

  def product_count
    total = 0
    salesman_travel_routes.each do |r|
      total += r.product_count
    end
    total
  end

  def full_name
    "#{created_at.strftime('%m/%d %H:%M')}, Нярав: #{load_at.present? ? load_at.strftime('%m/%d %H:%M') : "-"}, Түгээгч: #{sign_at.present? ? sign_at.strftime('%m/%d %H:%M') : "-"} (#{salesman_travel_routes.count})"
  end

  def on_sign(user)
    now = Time.now
    if salesman_travel_routes.present?
      self.update_columns(load_at: now, delivery_at: now + (duration * 60), user_id: user.id)

      salesman_travel_routes.each do |route|
        to_time = now + (route.duration * 60)
        route.update_columns(load_at: now, delivery_at: to_time)
        now = to_time
      end

      notification = Notification.create(salesman: salesman,
                                         salesman_travel: self,
                                         title: I18n.t("api.user_sign"),
                                         body_s: I18n.t("api.body.user_sign_s", user: user.name, routes: self.salesman_travel_routes.count),
                                         body_u: I18n.t("api.body.user_sign_u", user: salesman.name, products: ProductSaleItem.count_item_quantity(self.id)))
      ApplicationController.helpers.send_noti_salesman(salesman,
                                                       ApplicationController.helpers.push_options('user_sign',
                                                                                                  self.id,
                                                                                                  notification.title,
                                                                                                  notification.body_s))
    end
  end

  def salesman_sign
    self.update_column(:sign_at, Time.now)

    notification = Notification.create(user: user,
                                       salesman_travel: self,
                                       title: I18n.t("api.salesman_sign"),
                                       body_s: I18n.t("api.body.salesman_sign_s", routes: self.salesman_travel_routes.count),
                                       body_u: I18n.t("api.body.salesman_sign_u", user: salesman.name, products: ProductSaleItem.count_item_quantity(self.id)))
    ApplicationController.helpers.send_noti_user(user,
                                                 ApplicationController.helpers.push_options('salesman_sign',
                                                                                            self.id,
                                                                                            notification.title,
                                                                                            notification.body_u))
  end

  def calculate_delivery
    c = 0
    if salesman_travel_routes.present?
      salesman_travel_routes.each do |route|
        if route.delivered_at.present?
          c += 1
        end
      end

      # Бүгдийг хүргэсэн эсэхийг шалгаж байна
      if salesman_travel_routes.length == c
        self.delivered_at = Time.now
        self.delivery_time = ApplicationController.helpers.get_minutes(delivered_at, load_at)
      else
        self.delivered_at = nil
        self.delivery_time = nil
      end
      self.save
    end
  end

  def send_notification
    notification = Notification.create(salesman: salesman,
                                       n_type: 1,
                                       salesman_travel: self,
                                       title: I18n.t("api.distributing"),
                                       body_s: I18n.t("api.body.distributing_s", routes: self.salesman_travel_routes.count),
                                       body_u: I18n.t("api.body.distributing_u", user: self.salesman.name, products: ProductSaleItem.count_item_quantity(self.id)))
    ApplicationController.helpers.send_noti_salesman(salesman,
                                                     ApplicationController.helpers.push_options('distributing',
                                                                                                self.id,
                                                                                                notification.title,
                                                                                                notification.body_s))
    users = User.by_position_id(2)
    if users.present?
      ApplicationController.helpers.send_noti_users(users,
                                                    ApplicationController.helpers.push_options('distributing',
                                                                                               self.id,
                                                                                               notification.title,
                                                                                               notification.body_u))
    end
  end

  def check_only_back
    if product_sale_items.count == product_sale_items.is_quantity_lower(0).count
      now = Time.now
      self.update_columns(load_at: now, delivery_at: now + (duration * 60), sign_at: now)
      salesman_travel_routes.each do |route|
        to_time = now + (route.duration * 60)
        route.update_columns(load_at: now, delivery_at: to_time)
        now = to_time
      end

    end
  end
end
