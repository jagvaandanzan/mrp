class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_ability
    @current_ability ||= if current_user
                           AbilityUser.new(current_user)
                         else
                           current_operator ? AbilityOperator.new(current_operator) : AbilityAdmin.new(current_admin_user)
                         end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def search_product
    @list = Product.search_by_name(params[:text])
    @select_id = params[:id]

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

  def fb_comment_path
    if current_operator.present?
      redirect_to operators_fb_comment_path(id: params[:id])
    else
      redirect_to users_fb_comment_path(id: params[:id])
    end
  end

  def search_fb_answer
    @search_text = params[:text]
    if @search_text.length > 1
      @list = FbCommentAnswer.search(@search_text)
    end
    respond_to do |format|
      format.js {render 'shared/search_fb_answer'}
    end
  end

  def get_product_features
    features = []
    price = 0
    img_url = "/images/orignal/missing.png"

    if params[:product_id].present?
      product = Product.find(params[:product_id])
      img_url = product.picture.url(:tumb) if product.picture.present?
      price = product.price if product.price.present?
      product.product_feature_items.each do |item|
        features.push({id: item.id, name: item.name, balance: item.balance, product: product.id})
      end
    end

    render json: {price: price, features: features, tumb: img_url}
  end


end
