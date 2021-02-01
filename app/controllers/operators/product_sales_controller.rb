class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show, :update_status, :destroy]

  def index
    @product_name = params[:product_name]
    @status_id = params[:status_id]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]
    cookies[:product_sale_page_number] = params[:page]
    @product_sales = ProductSale.search(@product_name, @start, @finish, @phone, @status_id).page(params[:page])
  end

  def new
    if params[:sale_call_id].present?
      @product_sale = ProductSale.new
      sale_call = ProductSaleCall.find(params[:sale_call_id])
      @product_sale.sale_call = sale_call

      total_price = 0
      sale_call.product_call_items.each do |call_item|
        sale_item = ProductSaleItem.new(product: call_item.product)
        if call_item.feature_item.present?
          sale_item.feature_item = call_item.feature_item
          sale_item.remainder = ProductBalance.balance(call_item.product_id, call_item.feature_item_id)
          sale_item.quantity = call_item.quantity.presence || 0
          sale_item.price = call_item.feature_item.price.presence || 0
          sum_price = sale_item.price * sale_item.quantity
          sale_item.sum_price = sum_price
          total_price += sum_price
        end
        @product_sale.product_sale_items << sale_item
      end

      @product_sale.sum_price = total_price
      @product_sale.phone = sale_call.phone

      time = Time.current
      @product_sale.delivery_start = time
      @product_sale.hour_start = time.hour
      @product_sale.hour_now = time.hour
      @product_sale.hour_end = time.hour + 2
      @product_sale.status_user_type = 'operator'
      @product_sale.main_status_id = 2
      @product_sale.location = Location.offset(rand(Location.count)).first
      @product_sale.building_code = 4.times.map {rand(9)}.join
      @product_sale.loc_note = (4.times.map {rand(9)}.join) + ', ' + (4.times.map {rand(9)}.join)
      @product_sale.money = 0
    else
      redirect_to operators_product_sale_calls_path
    end
  end

  def search_locations
    @list = if params[:country].present?
              Location.search_by_country
            else
              Location.search_by_name(params[:text])
            end
    @select_id = params[:id]

    respond_to do |format|
      format.js {render 'operators/product_sales/search_results'}
    end
  end

  def create
    @product_sale = ProductSale.new(product_sale_params)
    @product_sale.created_operator = current_operator
    @product_sale.operator = current_operator
    check_approved(@product_sale)

    if @product_sale.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
      # redirect_to action: 'show', id: @product_sale.id
    else
      logger.debug(@product_sale.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @product_sale.status_user_type = 'operator'
    @product_sale.hour_start = @product_sale.delivery_start.hour
    @product_sale.hour_end = @product_sale.delivery_end.hour

    if params[:rc].present?
      @product_sale.main_status = @product_sale.status = ProductSaleStatus.find_by_alias("return_change")
    end
  end

  def destroy
    @product_sale.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def update
    @product_sale.attributes = product_sale_params
    check_approved(@product_sale)
    @product_sale.operator = current_operator

    if @product_sale.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def update_status
    @product_sale.update_status = true
    @product_sale.attributes = params.require(:product_sale).permit(:main_status_id, :status_id, :status_note, :status_user_type)
    @product_sale.operator = current_operator
    check_approved(@product_sale)

    if @product_sale.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'show'
      logger.debug(@product_sale.errors.full_messages)
    end

  end

  def show
  end

  def get_sub_status
    subs = nil

    if params[:parent_id].present?
      subs = ProductSaleStatus.search(params[:parent_id], params[:status_user_type])
    end

    render json: {subs: subs}
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
        features.push({id: item.id, name: item.name, balance: ProductBalance.balance(product.id, item.id), product: product.id})
      end
    end

    render json: {price: price, features: features, tumb: img_url}
  end

  def add_location

    location = Location.create(
        operator: current_operator,
        loc_khoroo_id: params[:khoroo_id],
        name: params[:name],
        name_la: params[:name_la],
        distance: params[:distance],
        latitude: params[:latitude],
        longitude: params[:longitude])

    if location.valid?
      render json: {status: :ok, id: location.id, name: location.full_name}
    else
      render json: {status: :error, error: location.errors.full_messages}
    end

  end

  def search_khoroos
    @list = LocKhoroo.search(params[:id], nil)
    @select_id = 'location_loc_khoroo_id'

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

  def get_last_location
    latitude = 47.918772
    longitude = 106.917609

    locations = Location.where("loc_khoroo_id = ?", params[:khoroo_id])
    if locations.present?
      location_last = locations.last
      latitude = location_last.latitude
      longitude = location_last.longitude
    end

    render json: {latitude: latitude, longitude: longitude}
  end

  def get_location
    location = Location.find(params[:id])
    if location.present?
      render json: {latitude: location.latitude, longitude: location.longitude}
    end
  end

  def get_product_balance
    feature_item_id = params[:feature_item_id]
    product_balance = ProductBalance.balance(params[:product_id], feature_item_id)
    feature_item = ProductFeatureItem.find(feature_item_id)
    render json: {balance: product_balance,
                  price: feature_item.price.presence || 0,
                  img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png',
                  tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png'}
  end

  def auto
  end

  def auto_form
    amount = params[:amount]
    logger.info(amount)

    product_sale = ProductSale.new
    product_sale.product_sale_items.push(ProductSaleItem.new)
    time = Time.current
    product_sale.delivery_start = time
    product_sale.hour_start = time.hour
    product_sale.hour_now = time.hour
    product_sale.hour_end = time.hour + 2
    product_sale.status_user_type = 'operator'


    redirect_to auto_operators_product_sales_path
  end

  private

  def set_product_sale
    @product_sale = ProductSale.find(params[:id])
  end

  def check_approved(product_sale)
    if product_sale.main_status.present?
      if product_sale.main_status.alias == "approved"
        product_sale.approved_operator = current_operator
        product_sale.approved_date = Time.current
      else
        product_sale.approved_operator = nil
        product_sale.approved_date = nil
      end
    end
  end

  def product_sale_params
    params.require(:product_sale)
        .permit(:sale_call_id, :phone, :delivery_start, :hour_start, :hour_end, :location_id, :country, :building_code, :loc_note,
                :sum_price, :money, :paid, :bonus, :tax,
                :main_status_id, :status_id, :status_note, :status_user_type,
                product_sale_items_attributes: [:id, :product_id, :feature_item_id, :to_see, :quantity, :price, :sum_price, :remainder, :_destroy])
  end
end
