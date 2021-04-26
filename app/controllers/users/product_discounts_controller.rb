class Users::ProductDiscountsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_discount, only: [:edit, :update, :destroy]

  def new
    product_id = params[:pid]
    feature = ProductFeatureItem.by_product_id(product_id).limit(1).first
    @product_discount = ProductDiscount.new
    @product_discount.product_id = product_id
    @product_discount.real_price = feature.price
    @product_discount.price = feature.price
  end

  def create
    @product_discount = ProductDiscount.new(product_discount_params)
    if @product_discount.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to users_product_path(@product_discount.product, tab_index: 5)
    else
      Rails.logger.debug(@product_discount.errors.full_messages)
      render 'new'
    end
  end


  def edit
    feature = ProductFeatureItem.by_product_id(@product_discount.product_id).limit(1).first
    @product_discount.real_price = feature.price
  end


  def update
    @product_discount.attributes = product_discount_params
    if @product_discount.save
      flash[:success] = t('alert.info_updated')
      redirect_to users_product_path(@product_discount.product, tab_index: 5)
    else
      render 'edit'
    end
  end

  def destroy
    @product_discount.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to users_product_path(@product_discount.product, tab_index: 5)
  end


  private

  def set_product_discount
    @product_discount = ProductDiscount.find(params[:id])
  end

  def product_discount_params
    params.require(:product_discount).permit(:product_id, :price, :real_price, :start_date, :end_date)
        .merge(user: current_user)
  end

end
