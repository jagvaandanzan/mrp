class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show, :update_status, :destroy]

  def index
    @product_name = params[:product_name]
    @status_id = params[:status_id]
    @status = params[:status]
    @status_sub = params[:status_sub]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]
    cookies[:product_sale_page_number] = params[:page]
    status_alias = if @status_id.present?
                     s = ProductSaleStatus.find(@status_id)
                     s.alias
                   end
    @product_sales = ProductSale.search(@product_name, @start, @finish, @phone, status_alias).page(params[:page])
  end

  def new
    if params[:sale_call_id].present? || params[:parent_id].present?
      @product_sale = ProductSale.new
      total_price = 0
      if params[:sale_call_id].present?
        sale_call = ProductSaleCall.find(params[:sale_call_id])
        @product_sale.sale_call = sale_call

        sale_call.product_call_items.each do |call_item|
          product = call_item.product
          sale_item = ProductSaleItem.new(product: product)
          if call_item.feature_item.present?
            feature_item = call_item.feature_item
            sale_item.feature_item = feature_item
            sale_item.remainder = feature_item.balance
            sale_item.quantity = call_item.quantity.presence || 0
            sale_item.p_price = feature_item.price.presence || 0
            sale_item.p_6_8 = feature_item.p_6_8.presence || 0
            sale_item.p_9_ = feature_item.p_9_.presence || 0
            sale_item.price = feature_item.price_quantity(sale_item.quantity).presence || 0
            # Хэрэв хямдралтай бол
            product_discounts = product.product_discounts.by_available
            if product_discounts.present?
              discount = product_discounts.first
              sale_item.discount = discount.percent
              sale_item.price -= ApplicationController.helpers.get_percentage(sale_item.price, discount.percent)
            end
            sum_price = sale_item.price * sale_item.quantity
            sale_item.sum_price = sum_price
            total_price += sum_price
          end
          @product_sale.product_sale_items << sale_item
        end
        @product_sale.phone = sale_call.phone

        @product_sale.location = Location.offset(rand(Location.count)).first
        @product_sale.building_code = 4.times.map {rand(9)}.join
        @product_sale.loc_note = (4.times.map {rand(9)}.join) + ', ' + (4.times.map {rand(9)}.join)
        @product_sale.money = 0

        #   Буцаалт, солилт бол
      elsif params[:parent_id].present?
        parent = ProductSale.find(params[:parent_id])
        @product_sale.parent_id = parent.id
        @product_sale.phone = parent.phone
        @product_sale.location = parent.location
        @product_sale.country = parent.country
        @product_sale.building_code = parent.building_code
        @product_sale.loc_note = parent.loc_note
        @product_sale.money = parent.money
        @product_sale.paid = parent.paid
        @product_sale.bonus = parent.bonus
        @product_sale.tax = parent.tax

        parent.product_sale_items.each do |item|
          product = item.product
          sale_item = ProductSaleItem.new(product: product)
          feature_item = item.feature_item
          sale_item.feature_item = feature_item
          sale_item.quantity = item.quantity.presence || 0
          sale_item.remainder = feature_item.balance + sale_item.quantity
          sale_item.p_price = feature_item.price.presence || 0
          sale_item.p_6_8 = feature_item.p_6_8.presence || 0
          sale_item.p_9_ = feature_item.p_9_.presence || 0
          sale_item.price = feature_item.price_quantity(sale_item.quantity).presence || 0
          sale_item.to_see = item.to_see
          sale_item.parent = item
          # Хэрэв хямдралтай бол
          product_discounts = product.product_discounts.by_available
          if product_discounts.present?
            discount = product_discounts.first
            sale_item.discount = discount.percent
            sale_item.price -= ApplicationController.helpers.get_percentage(sale_item.price, discount.percent)
          end
          sum_price = sale_item.price * sale_item.quantity
          sale_item.sum_price = sum_price
          total_price += sum_price
          @product_sale.product_sale_items << sale_item
        end
      end

      total_price += total_price < Const::FREE_SHIPPING ? Const::SHIPPING_FEE : 0
      @product_sale.sum_price = total_price

      time = Time.current
      @product_sale.delivery_start = time
      @product_sale.hour_start = time.hour
      @product_sale.hour_now = time.hour
      @product_sale.hour_end = time.hour + 2

    else
      redirect_to operators_product_sale_calls_path
    end
  end

  def search_locations
    @list = Location.search_by_name(params[:text], params[:country])
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
    if @product_sale.child.present?
      redirect_to action: :show, id: @product_sale.id
    else

      @product_sale.hour_start = @product_sale.delivery_start.hour
      @product_sale.hour_end = @product_sale.delivery_end.hour
      @product_sale.sum_price += @product_sale.bonus if @product_sale.bonus.present?
      @product_sale.product_sale_items.each do |item|
        feature_item = item.feature_item
        item.remainder = feature_item.balance + item.quantity
        item.p_price = feature_item.price.presence || 0
        item.p_6_8 = feature_item.p_6_8.presence || 0
        item.p_9_ = feature_item.p_9_.presence || 0
      end
      @product_sale.set_statuses(false)
    end
  end

  def destroy
    if @product_sale.child.present?
      redirect_to action: :show, id: @product_sale.id
    else
      @product_sale.destroy!
      flash[:success] = t('alert.deleted_successfully')
      redirect_to action: 'index'
    end
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
    @product_sale.attributes = params.require(:product_sale).permit(:status_id, :status_m, :status_sub, :status_note)
    @product_sale.operator = current_operator
    check_approved(@product_sale)

    if @product_sale.save
      flash[:success] = t('alert.info_updated')
      if @product_sale.status.alias == "oper_replacement" ||
          @product_sale.status.alias == "oper_return" # ||@product_sale.status.alias == "oper_affliction"
        redirect_to new_operators_product_sale_path(parent_id: @product_sale.id)
      else
        redirect_to action: :index
      end
    else
      render 'show'
      logger.debug(@product_sale.errors.full_messages)
    end

  end

  def show
    @product_sale.set_statuses(true)
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

  def add_location

    location = Location.create(
        operator: current_operator,
        loc_khoroo_id: params[:khoroo_id],
        micro_region: params[:micro_region],
        town: params[:town],
        street: params[:street],
        apartment: params[:apartment],
        entrance: params[:entrance],
        station_id: params[:station_id],
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
    feature_item = ProductFeatureItem.find(feature_item_id)
    render json: {balance: feature_item.balance,
                  price: feature_item.price.presence || 0,
                  p_9_: feature_item.p_9_.presence || 0,
                  p_6_8: feature_item.p_6_8.presence || 0,
                  img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png',
                  tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png'}
  end

  def get_bonus
    bonus = if params[:phone].length == 8
              bonu = Bonu.by_phone(params[:phone])
              if bonu.present?
                b = bonu.first
                b.balance
              else
                0
              end
            else
              0
            end
    render json: {bonus: bonus}
  end

  def next_status
    @id = params[:id]
    @select_id = params[:select_id]

    status = ProductSaleStatus.find(@id)
    if status.next.present?
      ids = status.next.split(",").map(&:to_i)
      @list = ProductSaleStatus.by_ids(ids)
    end

    respond_to do |format|
      format.js {render 'shared/product_status'}
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

    redirect_to auto_operators_product_sales_path
  end

  private

  def set_product_sale
    @product_sale = ProductSale.find(params[:id])
  end

  def check_approved(product_sale)
    if product_sale.status.present?
      if product_sale.status.alias == "oper_confirmed"
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
        .permit(:sale_call_id, :parent_id, :phone, :delivery_start, :hour_start, :hour_end, :location_id, :country, :building_code, :loc_note,
                :sum_price, :money, :paid, :bonus, :tax,
                :status_id, :status_m, :status_sub, :status_note,
                product_sale_items_attributes: [:id, :product_id, :parent_id, :feature_item_id, :to_see, :quantity, :price, :p_discount, :discount, :sum_price, :remainder, :_destroy])
  end
end
