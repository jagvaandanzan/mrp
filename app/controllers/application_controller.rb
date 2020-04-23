class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_ability
    @current_ability ||= if current_user
                           AbilityUser.new(current_user)
                         else
                           @current_ability == current_operator ? AbilityOperator.new(current_operator) : AbilityAdmin.new(current_admin_user)
                         end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def search_product
    @list = Product.search(params[:text])
    @select_id = params[:id]

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

end
