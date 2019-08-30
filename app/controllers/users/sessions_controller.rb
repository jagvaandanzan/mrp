class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource_or_scope)
    users_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
