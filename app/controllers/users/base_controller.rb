class Users::BaseController < ApplicationController
  layout 'user'

  before_action do
    authenticate_user!
    redirect_to user_passwords_edit_password_path if current_user.password_is_reset
  end

  def root
    path = if can? :read, ProductSupplyOrder
             users_product_supply_orders_path
           elsif can? :read, ProductIncome
             users_product_incomes_path
           elsif can? :read, Product
             users_products_path
           elsif can? :read, Operator
             users_operators_path
           elsif can? :read, Location
             users_loc_districts_path
           elsif can? :read, ProductSupplier
             users_product_suppliers_path
           elsif can? :read, ProductLocation
             users_product_locations_path
           elsif can? :read, FbPost
             users_fb_posts_path
           else
             users_panel_path
           end

    redirect_to path
  end

  def routing_error
    redirect_to users_root_path
  end

end
