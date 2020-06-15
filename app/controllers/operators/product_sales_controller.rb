class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show, :update_status, :destroy]

  def index
    @product_name = params[:product_name]
    @status_id = params[:status_id]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]

    @product_sales = ProductSale.search(@product_name, @start, @finish, @phone, @status_id).page(params[:page])
  end

  def new
    @product_sale = ProductSale.new
    # Шинэ захиалга үүсгэх үед + товч дарагдсан гарч ирэх
    @product_sale.product_sale_items.push(ProductSaleItem.new(product: Product.offset(rand(Product.count)).first))
    time = Time.current
    @product_sale.delivery_start = time
    @product_sale.hour_start = time.hour
    @product_sale.hour_now = time.hour
    @product_sale.hour_end = time.hour + 2
    @product_sale.status_user_type = 'operator'


    @product_sale.phone = '99' + 6.times.map {rand(9)}.join
    @product_sale.main_status_id = 2
    @product_sale.location = Location.offset(rand(Location.count)).first
    @product_sale.building_code = 4.times.map {rand(9)}.join
    @product_sale.loc_note = (4.times.map {rand(9)}.join) +', ' + (4.times.map {rand(9)}.join)
  end

  def search_locations
    @list = Location.search_by_name(params[:text])
    @select_id = params[:id]

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

  def create
    @product_sale = ProductSale.new(product_sale_params)
    @product_sale.created_operator = current_operator
    check_approved(@product_sale)

    if @product_sale.save
      create_log(@product_sale)
      flash[:success] = t('alert.saved_successfully')

      redirect_to action: 'show', id: @product_sale.id
    else
      logger.debug(@product_sale.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @product_sale.status_user_type = 'operator'
    @product_sale.hour_start = @product_sale.delivery_start.hour
    @product_sale.hour_end = @product_sale.delivery_end.hour
  end

  def destroy
    @product_sale.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def update
    @product_sale.attributes = product_sale_params
    check_approved(@product_sale)

    if @product_sale.save
      create_log(@product_sale)
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def update_status
    @product_sale.update_status = true
    @product_sale.attributes = params.require(:product_sale).permit(:main_status_id, :status_id, :status_note, :status_user_type)
    check_approved(@product_sale)

    if @product_sale.save
      create_log(@product_sale)
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

    render json: {childrens: subs}
  end

  def get_product_features
    features = []
    price = 0
    if params[:product_id].present?

      feature_items = ProductFeatureItem.search(params[:product_id])

      feature_items.each do |item|
        features.push({id: item.id, name: item.name, price: item.price, product: params[:product_id]})
      end
    end

    render json: {price: price, childrens: features}
  end

  def add_location

    location = Location.create(
        operator: current_operator,
        loc_khoroo_id: params[:khoroo_id],
        name: params[:name],
        name_la: params[:name_la],
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
    render json: {balance: product_balance, img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png', tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png'}
  end

  def get_prev_sales
    @product_sales = ProductSale.search(nil, nil, nil, params[:phone], nil).first(3)
    respond_to do |format|
      format.js {render 'previous_sales'}
    end
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

  def create_log(product_sale)
    product_sale_status_log = ProductSaleStatusLog.new
    product_sale_status_log.product_sale = product_sale
    product_sale_status_log.operator = current_operator
    product_sale_status_log.status = product_sale.status
    product_sale_status_log.note = product_sale.status_note
    product_sale_status_log.save
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
        .permit(:phone, :delivery_start, :hour_start, :hour_end, :location_id, :building_code, :loc_note,
                :sum_price, :money, :paid, :bonus,
                :main_status_id, :status_id, :status_note, :status_user_type,
                product_sale_items_attributes: [:id, :product_id, :feature_item_id, :to_see, :quantity, :price, :sum_price, :remainder, :_destroy])
  end
end
