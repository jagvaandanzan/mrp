class Users::ProductSupplyOrdersController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_supply_order, only: [:edit, :show, :update, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]

    @product_supply_order_items = ProductSupplyOrderItem.search(@by_start, @by_end, @by_code, @by_product_name).page(params[:page])
  end

  def new
    @product_supply_order = ProductSupplyOrder.new
    @product_supply_order.ordered_date = Time.current
    @product_supply_order.code = ApplicationController.helpers.get_code(ProductSupplyOrder.last)

    @product_supply_order.product_supply_order_items << ProductSupplyOrderItem.new
  end

  def create
    @product_supply_order = ProductSupplyOrder.new(product_supply_order_params)
    if @product_supply_order.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to :action => 'show', id: @product_supply_order.id
    else
      logger.debug(@product_supply_order.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @product_supply_order.tab_index = params[:tab_index] if params[:tab_index].present?
    @product_supply_order.product_supply_order_items.each do |item|
      if item.supply_features.count == 0
        item.product.product_feature_items.each {|feature_item|
          item.supply_features << ProductSupplyFeature.new(feature_item: feature_item)
        }
      end
    end
  end

  def show
    @product_supply_order.tab_index = params[:tab_index] if params[:tab_index].present?
  end

  def update
    @product_supply_order.attributes = product_supply_order_params
    if @product_supply_order.save
      flash[:success] = t('alert.info_updated')
      if @product_supply_order.product_supply_order_items.count > 0
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
      product_supply_order = @order_item.product_supply_order
      if product_supply_order.product_supply_order_items.count == @order_item.tab_index.to_i
        redirect_to action: 'index'
      else
        redirect_to action: :edit, id: params[:id], tab_index: @order_item.tab_index.to_i + 1
      end
    else
      render 'edit', id: params[:id]
    end
  end

  def destroy
    @product_supply_order.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def last_product_price
    price = 0
    order_items = ProductSupplyOrderItem.where(product_id: params[:product_id])

    if order_items.present?
      price = order_items.last.price
    end

    render json: {price: price}

  end

  private

  def set_product_supply_order
    @product_supply_order = ProductSupplyOrder.find(params[:id])
  end

  def product_supply_order_params
    params.require(:product_supply_order).permit(:code, :ordered_date, :supplier_id, :payment, :exchange, :exchange_value, :is_closed, :closed_date,
                                                 product_supply_order_items_attributes: [:id, :product_id, :note, :_destroy])
        .merge(:user => current_user)
  end

  def form_feature_params
    params.require(:product_supply_order_item).permit(:tab_index,
                                                      supply_features_attributes: [:id, :quantity, :price, :note, :is_create, :_destroy])
  end
end
