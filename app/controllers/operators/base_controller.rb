class Operators::BaseController < ApplicationController
  layout 'operator'

  before_action do
    authenticate_operator!
    redirect_to operator_passwords_edit_password_path if current_operator.password_is_reset
  end

  def routing_error
    redirect_to operators_root_path
  end

end
