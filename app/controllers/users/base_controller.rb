class Users::BaseController < ApplicationController
  layout 'user'

  before_action do
    authenticate_user!
    redirect_to user_passwords_edit_password_path if current_user.password_is_reset
  end

  def routing_error
    redirect_to users_root_path
  end

end
