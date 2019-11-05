class ApplicationController < ActionController::Base

  def current_ability
    @current_ability ||= current_user ? Ability.new(current_user) : AdminAbility.new(current_admin_user)
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
