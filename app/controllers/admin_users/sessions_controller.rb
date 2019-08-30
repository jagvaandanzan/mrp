class AdminUsers::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource_or_scope)
    admin_users_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_admin_user_session_path
  end
end
