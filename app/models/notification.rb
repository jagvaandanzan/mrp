class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :salesman, optional: true
  belongs_to :salesman_travel, optional: true
  belongs_to :return_sign, :class_name => "SalesmanReturnSign", optional: true
  belongs_to :product_sale_item, optional: true

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
        .order(created_at: :desc)
  }
  scope :by_user, ->(user_id) {
    where(user_id: user_id)
        .or(where(n_type: 1))
        .order(created_at: :desc)
  }

  def avatar_s
    if salesman.present?
      salesman.avatar_tumb
    else
      "/orignal/missing.png"
    end
  end

  def avatar_u
    "/orignal/missing.png"
  end

  def created_at
    self[:created_at].strftime('%F %R') if self[:created_at].present?
  end

end
