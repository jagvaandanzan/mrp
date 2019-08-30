class AdminUsers::BaseController < ApplicationController
  layout 'admin'

  before_action do
    authenticate_admin_user!
    redirect_to admin_passwords_edit_password_path if current_admin_user.password_is_reset
  end

  def routing_error
    redirect_to admin_users_root_path
  end
end
