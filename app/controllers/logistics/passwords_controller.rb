class Logistics::PasswordsController < Devise::PasswordsController
  def after_sign_in_path_for(resource_or_scope)
    logistics_root_path
  end
end
