class Logistics::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource_or_scope)
    logistics_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_logistic_session_path
  end
end
