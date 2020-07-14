class Users::ProductSamplesController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_sample, only: [:edit, :show, :update, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]

    @product_supply_order_items = ProductSupplyOrderItem.search_by_sample(@by_start, @by_end, @by_code, @by_product_name).page(params[:page])
  end

  def new
    @product_sample = ProductSample.new
    @product_sample.ordered_date = Time.current
    @product_sample.code = ApplicationController.helpers.get_code(ProductSample.last)
    @product_sample.product_supply_order_items << ProductSupplyOrderItem.new
  end

  def create
    @product_sample = ProductSample.new(product_sample_params)
    if @product_sample.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :edit, id: @product_sample.id, tab_index: 1
    else
      logger.debug(@product_sample.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @product_sample.tab_index = params[:tab_index] if params[:tab_index].present?
    product = @product_sample.get_product
    if product.present?
      @product_sample.option_rels = product.product_feature_option_rels.map {|i| i.feature_option_id.to_s}.to_a
      @product_sample.product_name = product.name
    end

    @product_sample.product_supply_order_items.each(&:set_supply_feature)
  end

  def show
    @product_sample.tab_index = params[:tab_index] if params[:tab_index].present?
    product = @product_sample.get_product
    if product.present?
      @product_sample.option_rels = product.product_feature_option_rels.map {|i| i.feature_option_id.to_s}.to_a
      @product_sample.product_name = product.name_en
    end
  end

  def update
    @product_sample.attributes = product_sample_params
    if @product_sample.save
      flash[:success] = t('alert.info_updated')
      if @product_sample.product_supply_order_items.count > 0
        redirect_to action: :edit, id: params[:id], tab_index: 1
      else
        redirect_to action: 'index'
      end
    else
      render 'edit'
    end
  end

  def form_feature
    @order_item = ProductSupplyOrderItem.find(params[:item_id])
    @order_item.attributes = form_feature_params
    if @order_item.save
      @order_item.set_sum_price

      flash[:success] = t('alert.info_updated')
      product_sample = @order_item.product_sample
      if product_sample.product_supply_order_items.count == @order_item.tab_index.to_i
        redirect_to action: 'index'
      else
        redirect_to action: :edit, id: params[:id], tab_index: @order_item.tab_index.to_i + 1
      end
    else
      render 'edit', id: params[:id]
    end
  end

  def destroy
    @product_sample.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_sample
    @product_sample = ProductSample.find(params[:id])
  end

  def product_sample_params
    params.require(:product_sample).permit(:tab_index, :code, :ordered_date, :logistic_id, :exchange, :product_name, :link, :description, option_rels: [],
                                           product_sample_images_attributes: [:id, :image, :_destroy])
        .merge(:user => current_user)
  end

  def form_feature_params
    params.require(:product_supply_order_item).permit(:tab_index,
                                                      supply_features_attributes: [:id, :quantity, :price, :note, :is_create, :_destroy])
  end

end
