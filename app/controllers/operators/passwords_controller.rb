class Operators::PasswordsController < Devise::PasswordsController
  def after_sign_in_path_for(resource_or_scope)
    operators_root_path
  end
end
