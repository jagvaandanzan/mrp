class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show, :update_status, :destroy]

  def index
    current_operator.clear_active_call
    @product_name = params[:product_name]
    @status_id = params[:status_id]
    @status = params[:status]
    @status_sub = params[:status_sub]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]
    @salesman_id = params[:salesman_id]
    cookies[:product_sale_page_number] = params[:page]
    status_alias = if @status_id.present?
                     s = ProductSaleStatus.find(@status_id)
                     s.alias
                   end
    @product_sales = ProductSale.search(@product_name, @start, @finish, @phone, status_alias, @salesman_id).page(params[:page])
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
        @product_sale.source = sale_call.source
        total_price += total_price < Const::FREE_SHIPPING ? Const::SHIPPING_FEE : 0

        # @product_sale.location = Location.offset(rand(Location.count)).first
        # @product_sale.building_code = 4.times.map {rand(9)}.join
        # @product_sale.loc_note = (4.times.map {rand(9)}.join) + ', ' + (4.times.map {rand(9)}.join)
        # @product_sale.money = 0

        #   Буцаалт, солилт бол
      elsif params[:parent_id].present?
        parent = ProductSale.find(params[:parent_id])
        @product_sale.parent_id = parent.id
        @product_sale.phone = parent.phone
        @product_sale.location = parent.location
        @product_sale.country = parent.country
        @product_sale.building_code = parent.building_code
        @product_sale.loc_note = parent.loc_note
        @product_sale.tax = parent.tax
        @product_sale.sum_price = -parent.sum_price
        parent.product_sale_items.not_nil_bought_quantity.each do |item|
          sale_return = ProductSaleReturn.new(product_sale: parent,
                                              product_sale_item: item,
                                              quantity: item.bought_quantity.presence || 0,
                                              remainder: item.bought_quantity.presence || 0)
          total_price -= item.price * item.bought_quantity
          @product_sale.product_sale_returns << sale_return
        end
      end

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
    if @product_sale.child.present? || !((can? :manage, :edit_product_sale) || !@product_sale.has_seen_stockkeeper)
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

      @radius_sales = radius_sales(@product_sale.delivery_start.beginning_of_day,
                                   @product_sale.location.latitude,
                                   @product_sale.location.longitude,
                                   @product_sale.id)
    end
  end

  def destroy
    if @product_sale.child.present? || !((can? :manage, :edit_product_sale) || !@product_sale.has_seen_stockkeeper)
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
      logger.debug(@product_sale.errors.full_messages)
      render 'show'
    end

  end

  def show
    SalesmanTravelJob.perform_later("sale", @product_sale)

    if @product_sale.status.alias == "oper_from_web"
      redirect_to action: :edit
    else
      @product_sale.set_statuses(true)
    end
  end

  def edit_location
    @location = params[:id].to_i > 0 ? Location.find(params[:id]) : Location.new(latitude: 47.918772, longitude: 106.917609)
    @location.my_id = params[:id]

    respond_to do |format|
      format.js {render 'operators/product_sales/ajax_location', locals: {hide_modal: false}}
    end
  end

  def update_location
    location = if params[:id].to_i > 0
                 Location.find(params[:id])
               else
                 Location.new
               end

    location.operator = current_operator
    location.loc_district_id = params[:loc_district_id]
    location.loc_khoroo_id = params[:loc_khoroo_id]
    location.micro_region = params[:micro_region]
    location.town = params[:town]
    location.street = params[:street]
    location.apartment = params[:apartment]
    location.entrance = params[:entrance]
    location.station_id = params[:station_id]
    location.name = params[:name]
    location.name_la = params[:name_la]
    location.latitude = params[:latitude]
    location.longitude = params[:longitude]

    if location.save
      render json: {status: :ok, id: location.id, name: location.full_name, latitude: location.latitude, longitude: location.longitude, is_country: location.loc_district.country}
    else
      render json: {status: :error, error: location.errors.full_messages}
    end
    # if params['location']['my_id'].to_i > 0
    #   @location = Location.find(params['location']['my_id'])
    #   @location.attributes = location_params
    # else
    #   @location = Location.new(location_params)
    # end
    # respond_to do |format|
    #   format.js {render 'operators/product_sales/ajax_location', locals: {hide_modal: false}}
    # end
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

  def get_product_balance
    feature_item_id = params[:feature_item_id]
    feature_item = ProductFeatureItem.find(feature_item_id)
    render json: {balance: feature_item.balance,
                  price: feature_item.price.presence || 0,
                  p_9_: feature_item.p_9_.presence || 0,
                  p_6_8: feature_item.p_6_8.presence || 0,
                  img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png',
                  tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png',
                  warehouse: feature_item.warehouse,
                  working_hours: feature_item.working_hours(params[:date].presence || Time.current)}
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

  def get_radius_sales
    @radius_sales = radius_sales(params[:delivery_start].to_date,
                                 params[:latitude],
                                 params[:longitude],
                                 params[:sale_id])
    respond_to do |format|
      format.js {render 'operators/product_sales/radius_sales'}
    end
  end

  def radius_sales(delivery_start, latitude, longitude, id)
    travel_config = TravelConfig.get_last
    radius = travel_config.sales_radius
    radius_sales = []
    items = ProductSale.by_delivery_between(delivery_start)
    items = items.where.not(id: id) if id.present?
    items.each do |sale|
      location = sale.location
      if Geocoder::Calculations.distance_between([latitude, longitude], [location.latitude, location.longitude], units: :km) <= radius
        radius_sales << sale
      end
    end
    radius_sales
  end

  def delete_item
    status = true
    message = ""
    sale_item = ProductSaleItem.find(params[:id])
    if sale_item.destroy
      ProductSaleLog.create(operator: current_operator,
                            o_product_id: sale_item.product_id,
                            o_feature_item_id: sale_item.feature_item_id,
                            o_quantity: sale_item.quantity,
                            o_to_see: sale_item.to_see,
                            o_p_discount: sale_item.p_discount,
                            o_discount: sale_item.discount)
      product = sale_item.product
      product.update_column(:balance, product.balance_sum)

      product_sale = sale_item.product_sale
      feature_item = sale_item.feature_item
      feature_item.update_column(:balance, feature_item.balance_sum)
      warehouse_locs = ProductWarehouseLoc.by_travel(product_sale.salesman_travel_id)
                           .by_feature_item_id(feature_item.id)
      q = sale_item.quantity
      if warehouse_locs.present?
        warehouse_locs.each do |loc|
          if q > 0
            if loc.quantity <= q
              loc.destroy
            else
              loc.update_column(:quantity, loc.quantity - q)
            end
            q -= loc.quantity
          else
            break
          end
        end
      end

      # Нийлбэр дүнг дахин бодох
      product_sale.update_sum_price
    else
      status = false
      message = sale_item.errors.full_messages
    end
    render json: {status: status, message: message}
  end

  def update_item
    status = true
    message = ""
    sale_item = if params[:id].to_i > 0
                  ProductSaleItem.find(params[:id])
                else
                  feature_item = ProductFeatureItem.find(params[:feature_item_id])
                  ProductSaleItem.new(product_sale_id: params[:sale_id],
                                      price: feature_item.price.presence || 0)
                end
    if sale_item.bought_at.present?
      status = false
      message = "Худалдан авалт хийсэн байна!"
    elsif sale_item.back_quantity.present?
      status = false
      message = "Буцаалт хийсэн байна!"
    else
      feature_item_id = sale_item.feature_item_id
      product_id = sale_item.product_id
      log = ProductSaleLog.new(operator: current_operator,
                               o_product_id: product_id,
                               o_feature_item_id: feature_item_id,
                               o_quantity: sale_item.quantity,
                               o_to_see: sale_item.to_see,
                               o_p_discount: sale_item.p_discount,
                               o_discount: sale_item.discount)
      sale_item.product_id = params[:product_id]
      sale_item.feature_item_id = params[:feature_item_id]
      sale_item.quantity = params[:quantity]
      sale_item.to_see = params[:to_see]
      sale_item.p_discount = params[:p_discount]
      sale_item.discount = params[:discount]
      log.product_id = sale_item.product_id
      log.feature_item_id = sale_item.feature_item_id
      log.quantity = sale_item.quantity
      log.to_see = sale_item.to_see
      log.p_discount = sale_item.p_discount
      log.discount = sale_item.discount

      price = if sale_item.p_discount.present?
                sale_item.p_discount
              elsif sale_item.discount.present?
                sale_item.price - ApplicationController.helpers.get_percentage(sale_item.discount, sale_item.price)
              else
                sale_item.price
              end
      sale_item.sum_price = sale_item.quantity * price
      sale_item.save
      log.save
      if product_id.present? && product_id != sale_item.product_id
        product = Product.find(product_id)
        product.update_column(:balance, product.balance_sum)
      end
      load_at = nil
      salesman_at = nil
      product_sale = sale_item.product_sale
      salesman_travel_id = product_sale.salesman_travel_id
      salesman_travel = SalesmanTravel.find(salesman_travel_id)
      warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
      if feature_item_id.present? && feature_item_id != sale_item.feature_item_id
        feature_item = ProductFeatureItem.find(feature_item_id)
        feature_item.update_column(:balance, feature_item.balance_sum)
        warehouse_locs = warehouse_locs.by_feature_item_id(feature_item_id)
        warehouse_locs.destroy_all if warehouse_locs.present?
      end
      if warehouse_locs.present?
        warehouse_loc = warehouse_locs.last
        load_at = warehouse_loc.load_at
        salesman_at = warehouse_loc.salesman_at
      end

      # Нийлбэр дүнг дахин бодох
      product_sale.update_sum_price

      create_warehouse_loc(salesman_travel.product_sale_items.by_feature_item_id(sale_item.feature_item_id).sum(:quantity),
                           salesman_travel_id,
                           sale_item.product_id,
                           sale_item.feature_item_id,
                           false, load_at, salesman_at)
    end
    render json: {status: status, message: message}
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
        .permit(:sale_call_id, :parent_id, :source, :phone, :delivery_start, :hour_start, :hour_end, :location_id, :country, :building_code, :loc_note,
                :sum_price, :money, :paid, :bonus, :tax,
                :status_id, :status_m, :status_sub, :status_note,
                product_sale_returns_attributes: [:id, :product_sale_item_id, :quantity, :remainder, :_destroy],
                product_sale_items_attributes: [:id, :product_id, :feature_item_id, :to_see, :quantity, :price, :p_discount, :discount, :sum_price, :remainder, :_destroy])
  end

  def location_params
    params.require(:location)
        .permit(:loc_district_id, :loc_khoroo_id, :micro_region, :town, :street, :apartment, :entrance, :name, :name_la, :station_id, :is_new, :latitude, :longitude)
        .merge(:operator => current_operator)
  end

end
