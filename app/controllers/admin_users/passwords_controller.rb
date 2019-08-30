class AdminUsers::PasswordsController < Devise::PasswordsController
  def after_sign_in_path_for(resource_or_scope)
    admin_users_root_path
  end
end
