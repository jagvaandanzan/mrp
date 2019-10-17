class ApplicationController < ActionController::Base

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
