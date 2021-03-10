class Logistics::BaseController < ApplicationController
  layout 'logistic'

  before_action do
    set_locale
    authenticate_logistic!
    redirect_to logistic_passwords_edit_password_path if current_logistic.password_is_reset
  end

  def root
    redirect_to logistics_supply_orders_path(order_type: 'basic')
  end

  def routing_error
    redirect_to logistics_supply_orders_path
  end

  def set_locale
    I18n.locale = params[:locale] || current_logistic.present? ? current_logistic.lang : 'mn'
  end

end
