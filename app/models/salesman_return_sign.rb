class SalesmanReturnSign < ApplicationRecord
  belongs_to :salesman
  belongs_to :user, optional: true
  has_many :salesman_returns, class_name: "SalesmanReturn", :foreign_key => "sign_id", dependent: :destroy

  has_attached_file :given, :path => ":rails_root/public/sign_return/:id_partition/given/:style.:extension", styles: {original: "600x600>"}, :url => '/sign_return/:id_partition/given/:style.:extension'
  validates_attachment :given,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

  has_attached_file :received, :path => ":rails_root/public/sign_return/:id_partition/received/:style.:extension", styles: {original: "600x600>"}, :url => '/sign_return/:id_partition/received/:style.:extension'
  validates_attachment :received,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

  after_create :send_notification
  attr_accessor :return_count

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  scope :by_user, ->(user_id) {
    if user_id.nil?
      where("user_id IS ?", nil)
    else
      where(user_id: user_id)
    end
  }

  def salesman_name
    salesman.name
  end

  def products
    salesman_returns.count
  end

  # send_notification
  def send_notification_to_salesman
    notification = Notification.create(user: self.user,
                                       return_sign: self,
                                       title: I18n.t("api.returned_product"),
                                       body_u: I18n.t("api.body.return_product_u", user: self.user.name, product: "#{salesman_returnsc.count}"))
    ApplicationController.helpers.send_noti_salesman(self.salesman,
                                                     ApplicationController.helpers.push_options('returned_product',
                                                                                                self.id,
                                                                                                notification.title,
                                                                                                notification.body_u))
  end

  private

  def send_notification
    notification = Notification.create(salesman: salesman,
                                       n_type: 1,
                                       return_sign: self,
                                       title: I18n.t("api.return_product"),
                                       body_u: I18n.t("api.body.return_product_s", user: self.salesman.name, products: "#{return_count}"))
    users = User.by_position_id(2)
    if users.present?
      ApplicationController.helpers.send_noti_users(users,
                                                    ApplicationController.helpers.push_options('return_product',
                                                                                               self.id,
                                                                                               notification.title,
                                                                                               notification.body_u))
    end
  end

end
