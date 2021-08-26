class Users::ProductSupplyOrdersController < Users::BaseController
  load_and_authorize_resource except: [:last_product_price, :set_calculated]
  before_action :set_product_supply_order, only: [:edit, :show, :update, :destroy, :to_product]

  def index
    month_1 = Time.current.strftime("%F")
    @by_start = params[:by_start] || Date.today - 30.days
    @by_end = params[:by_end] || Date.today
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    @order_type = params[:order_type]
    @is_equal = params[:is_equal]
    @product_supply_orders = ProductSupplyOrder.search(@by_start, @by_end, @by_code, @by_product_name, @order_type, @is_equal).page(params[:page])
    @product_supply_orders_x = ProductSupplyOrder.search(@by_start, @by_end, @by_code, @by_product_name, @order_type, @is_equal)
  end

  def new
    @product_supply_order = ProductSupplyOrder.new
    @product_supply_order.ordered_date = Time.current
    @product_supply_order.code = ApplicationController.helpers.get_order_code(ProductSupplyOrder.last)
    @product_supply_order.order_type = params[:order_type].to_i
    @product_supply_order.product_supply_order_items << ProductSupplyOrderItem.new
  end

  def create
    @product_supply_order = ProductSupplyOrder.new(product_supply_order_params)
    if @product_supply_order.save
      flash[:success] = t('alert.saved_successfully')
      if @product_supply_order.product_supply_order_items.count > 0
        redirect_to action: :edit, id: @product_supply_order.id, tab_index: 1
      else
        redirect_to action: 'index'
      end
    else
      logger.debug(@product_supply_order.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @product_supply_order.tab_index = params[:tab_index] if params[:tab_index].present?

    if @product_supply_order.is_sample?
      product = @product_supply_order.get_product
      if product.present?
        @product_supply_order.option_rels = product.product_feature_option_rels.map {|i| i.feature_option_id.to_s}.to_a
        @product_supply_order.product_name = product.name
      end
      @product_supply_order.product_supply_order_items.each(&:set_supply_feature)
    else
      @product_supply_order.product_supply_order_items.each do |item|
        if item.supply_features.count == 0
          item.product.product_feature_items.each {|feature_item|
            product_supply_features = ProductSupplyFeature.by_feature_item_id(feature_item.id)
            product_supply_feature = if product_supply_features.present?
                                       product_supply_features.last
                                     end
            item.supply_features << ProductSupplyFeature.new(feature_item: feature_item,
                                                             product_id: feature_item.product_id,
                                                             price: product_supply_feature.present? ? ApplicationController.helpers.get_f(product_supply_feature.price) : feature_item.price)
          }
        end
      end
    end
  end

  def show
    @product_supply_order.tab_index = params[:tab_index] if params[:tab_index].present?
    if @product_supply_order.is_sample?
      product = @product_supply_order.get_product
      if product.present?
        @product_supply_order.option_rels = product.product_feature_option_rels.map {|i| i.feature_option_id.to_s}.to_a
        @product_supply_order.product_name = product.name
      end
    end
  end

  def update
    @product_supply_order.attributes = product_supply_order_params
    if @product_supply_order.save
      flash[:success] = t('alert.info_updated')
      if @product_supply_order.product_supply_order_items.count > 0 &&
          @product_supply_order.product_supply_order_items.count != @product_supply_order.tab_index
        redirect_to action: :edit, id: params[:id], tab_index: @product_supply_order.tab_index.to_i + 1
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
      # Rails.logger.info("#{product_supply_order.product_supply_order_items.count} ==> #{@order_item.tab_index.to_i}")

      if product_supply_order.product_supply_order_items.count == @order_item.tab_index.to_i
        product_supply_order.set_status(1)
        @order_item.set_status(1)
        redirect_to action: 'index'
      else
        @order_item.set_status(1)
        redirect_to action: :edit, id: params[:id], tab_index: @order_item.tab_index.to_i + 1
      end
    else
      Rails.logger.info("order_item: #{@order_item.errors.full_messages}")
      redirect_to action: "edit", id: @product_supply_order.id, tab_index: @order_item.tab_index.to_i
    end
  end

  def destroy
    ids = @product_supply_order.supply_features.map(&:id).to_a
    er_features = ShippingErFeature.by_supply_feature_ids(ids)

    if er_features.present?
      flash[:alert] = t('alert.the_order_has_been_created')
      redirect_to action: 'show', id: @product_supply_order.id
    else
      @product_supply_order.destroy!
      flash[:success] = t('alert.deleted_successfully')
      redirect_to action: 'index'
    end
  end

  def last_product_price
    price = 0
    order_items = ProductSupplyOrderItem.where(product_id: params[:product_id])

    if order_items.present?
      price = order_items.last.price
    end

    render json: {price: price}

  end

  def to_excel
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    @order_type = params[:order_type]
    @is_equal = params[:is_equal]
    @product_supply_orders_x = ProductSupplyOrder.search(@by_start, @by_end, @by_code, @by_product_name, @order_type, @is_equal)
    respond_to do |format|
      format.xlsx{
        render template: 'users/product_supply_orders/index', xlsx: 'Худалдан авсан'
      }
      format.html {render 'users/product_supply_orders/index'}
    end
  end

  def to_product
    product = @product_supply_order.products.first
    if product.present? && product.draft
      quantity = @product_supply_order.supply_features.sum(:quantity)
      income_product_quantity = ProductIncomeProduct.by_product(product.id).sum(:quantity)
      if quantity == income_product_quantity
        product.update_column(:draft, false)
        product.sync_web('post')
        ProductPackage.create(product: product)

        redirect_to edit_users_product_path(product, tab_index: 0)
      else
        flash[:alert] = "Захиалга орлогод авч дуусаагүй байна!"
        redirect_to action: :show, id: @product_supply_order.id
      end
    else
      redirect_to action: 'index'
    end
  end

  private

  def set_product_supply_order
    @product_supply_order = ProductSupplyOrder.find(params[:id])
  end

  def product_supply_order_params
    params.require(:product_supply_order).permit(:tab_index, :order_type, :ordered_date, :logistic_id, :exchange, :product_name, :link, :description, option_rels: [],
                                                 product_supply_order_items_attributes: [:id, :product_id, :note, :_destroy],
                                                 product_sample_images_attributes: [:id, :image, :_destroy])
        .merge(:user => current_user)
  end

  def form_feature_params
    params.require(:product_supply_order_item).permit(:tab_index,
                                                      supply_features_attributes: [:id, :quantity, :price, :note, :is_create, :_destroy])
  end
end
