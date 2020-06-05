class Logistics::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!, only: [:edit_password, :update_password]

  def new
    redirect_to logistics_root_path
  end

  def create
    redirect_to logistics_root_path
  end

  def edit_password
    set_minimum_password_length
  end

  def update_password
    if self.resource.update(password_params)
      # Sign in the logistic by passing validation in case their password changed
      bypass_sign_in resource
      redirect_to logistics_root_path
    else
      render 'edit_password'
    end
  end

  private

  def password_params
    permitted = params.require(:logistic).permit(:password, :password_confirmation)
    permitted.merge!({:password_is_reset => false})
  end
end
