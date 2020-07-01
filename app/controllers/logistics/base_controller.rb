class Logistics::BaseController < ApplicationController
  layout 'logistic'

  before_action do
    authenticate_logistic!
    redirect_to logistic_passwords_edit_password_path if current_logistic.password_is_reset
  end

  def root
    redirect_to logistics_supply_orders_path
  end

  def routing_error
    redirect_to logistics_supply_orders_path
  end

end
