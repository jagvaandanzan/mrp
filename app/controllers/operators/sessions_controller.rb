class Operators::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource_or_scope)
    operators_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_operator_session_path
  end
end
