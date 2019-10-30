class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show]

  def index
    @code = params[:code]
    @status_id = params[:status_id]
    @location_id = params[:location_id]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]

    @product_sales = ProductSale.search(@code, @start, @finish, @phone, @status_id, @location_id).page(params[:page])
  end

  def new
    @product_sale = ProductSale.new
    # Шинэ захиалга үүсгэх үед + товч дарагдсан гарч ирэх
    @product_sale.product_sale_items.push(ProductSaleItem.new)
    time = Time.current
    @product_sale.delivery_start = time
    @product_sale.hour_start = time.hour
    @product_sale.hour_now = time.hour
    @product_sale.hour_end = time.hour + 2
    @product_sale.status_user_type = 'operator'
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

    if @product_sale.status.present? && @product_sale.status.alias == "approved"
      @product_sale.approved_operator = current_operator
      @product_sale.approved_date = Time.current
    end

    if @product_sale.save
      @product_sale_status_log = ProductSaleStatusLog.new
      @product_sale_status_log.product_sale = @product_sale
      @product_sale_status_log.operator = current_operator
      @product_sale_status_log.status = @product_sale.status
      @product_sale_status_log.note = @product_sale.status_note

      if @product_sale_status_log.save
        flash[:success] = t('alert.saved_successfully')
      else
        flash[:success] = t('alert.info_updated')
      end

      redirect_to action: :index
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

  def update
    @product_sale.attributes = product_sale_params

    if @product_sale.status.present? && @product_sale.status.alias == "approved"
      @product_sale.approved_operator = current_operator
      @product_sale.approved_date = Time.current
    end

    if @product_sale.save
      @product_sale_status_log = ProductSaleStatusLog.new
      @product_sale_status_log.product_sale = @product_sale
      @product_sale_status_log.operator = current_operator
      @product_sale_status_log.status = @product_sale.status
      @product_sale_status_log.note = @product_sale.status_note

      if @product_sale_status_log.save
        flash[:success] = t('alert.info_updated')
      else
        flash[:success] = t('alert.info_updated')
      end

      redirect_to action: :index
    else
      render 'edit'
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
      product = Product.find(params[:product_id])

      price = product.sale_price if product.present? && product.sale_price.present?

      feature_rels = ProductFeatureRel.search(params[:product_id])

      feature_rels.each do |rel|
        features.push({id: rel.id, name: rel.rel_names, price: rel.discount_price, product: params[:product_id]})
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
    product_balance = ProductBalance.balance(params[:product_id], params[:feature_rel_id])
    render json: {balance: product_balance}
  end

  private

  def set_product_sale
    @product_sale = ProductSale.find(params[:id])
  end

  def product_sale_params
    params.require(:product_sale)
        .permit(:phone, :delivery_start, :hour_start, :hour_end, :location_id, :building_code, :loc_note,
                :sum_price, :money, :bonus,
                :main_status_id, :status_id, :status_note, :status_user_type,
                product_sale_items_attributes: [:id, :product_id, :product_feature_rel_id, :quantity, :price, :sum_price, :remainder, :_destroy])
  end
end
