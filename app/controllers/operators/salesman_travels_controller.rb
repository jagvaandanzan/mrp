class Operators::SalesmanTravelsController < Operators::BaseController
  load_and_authorize_resource only: [:index, :new, :map, :zone, :edit, :update]
  before_action :set_salesman_travel, only: [:show, :edit, :update, :destroy]

  def index
    today = Time.current.beginning_of_day
    @start = params[:start].presence || today.strftime("%Y/%m/%d")
    @finish = params[:finish].presence || today.strftime("%Y/%m/%d")

    @salesman_travels = SalesmanTravel.search(DateTime.parse(@start), DateTime.parse(@finish))
                            .page(params[:page])
    cookies[:salesman_travel_page_number] = params[:page]
  end

  def zone
    @zones = LocationZone.order_queue
    @product_sales = ProductSale.travel_nil(nil)
    @salesman_requests = SalesmanRequest.by_travel_nil
  end

  def map
    @product_sales = ProductSale.travel_nil(nil)
  end

  def new
    @salesman_travel = SalesmanTravel.new
    @salesman_travel.operator_id = current_operator.id

    last_travel = SalesmanTravel.all.last
    @salesman_travel.number = last_travel.present? ? last_travel.id + 1 : 1
    @salesman_travel.sale_ids = params[:sale_ids]
    @salesman_travel.allocation = params[:allocation]
    if params[:zone_ids].present?
      @salesman_travel.zone_ids = params[:zone_ids]
    end
    @salesman_requests = SalesmanRequest.by_travel_nil

    respond_to do |format|
      format.js {render 'operators/salesman_travels/get_salesman', locals: {hide_modal: false}}
    end
  end

  def create
    @salesman_travel = SalesmanTravel.new(salesman_travel_params)
    @salesman_travel.operator = current_operator
    @salesman_travel.distance = 0
    @salesman_travel.duration = 0

    salesman_requests = SalesmanRequest.by_travel_nil
                            .by_salesman_id(@salesman_travel.salesman_id)
    if salesman_requests.present?
      save_action = @salesman_travel.save
      if save_action
        @salesman_travel.sale_ids.split(",").map(&:to_i).each_with_index {|sale_id, i|
          product_sale = ProductSale.find(sale_id)
          product_sale.update_column(:salesman_travel_id, @salesman_travel.id)
          product_sale.sent_info_to_user if !product_sale.product_sale_items.present? && product_sale.product_sale_returns.present?
          travel_route = SalesmanTravelRoute.new
          travel_route.queue = i
          travel_route.distance = 0
          travel_route.duration = 0
          travel_route.salesman_travel = @salesman_travel
          travel_route.location = product_sale.location
          travel_route.product_sale = product_sale
          travel_route.save
        }
        # Жолоочийн хүсэлт илгээсэнд үүсгэсэн хувиарлалтаа өгнө
        salesman_requests = SalesmanRequest.by_travel_nil
                                .by_salesman_id(@salesman_travel.salesman_id)
        if salesman_requests.present?
          salesman_request = salesman_requests.first
          salesman_request.update_column(:salesman_travel_id, @salesman_travel.id)
        end

        @salesman_travel.send_notification if @salesman_travel.product_count > 0

      else
        last_travel = SalesmanTravel.all.last
        @salesman_travel.number = last_travel.id + 1
        @salesman_requests = SalesmanRequest.by_travel_nil
      end
    else
      @salesman_travel.errors.add(:salesman_travel_id, "Хүсэлт илгээгээгүй байна!")
      save_action = false
    end

    respond_to do |format|
      format.js {
        render 'operators/salesman_travels/get_salesman', locals: {hide_modal: save_action}
      }
    end
  end

  def show
  end

  def insert_sale
    respond_to do |format|
      format.js {render 'operators/salesman_travels/insert_sale', locals: {product_sales: ProductSale.travel_nil(nil), hide_modal: false}}
    end
  end

  def insert_to_sale
    product_sale = ProductSale.find(params[:product_sale_id])
    salesman_travel_id = params[:travel_id]
    if product_sale.salesman_travel.present?
      render json: {success: false, errors: "Хувиарлагдсан захиалга байна"}
    else
      travel_route = SalesmanTravelRoute.new
      travel_route.queue = params[:queue]
      travel_route.distance = 0
      travel_route.duration = 0
      travel_route.salesman_travel_id = salesman_travel_id
      travel_route.location = product_sale.location
      travel_route.product_sale = product_sale

      if travel_route.save
        product_sale.update_column(:salesman_travel_id, salesman_travel_id)
        warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
        hash_locs = warehouse_locs.map {|i| [i.feature_item_id]}.to_h
        product_sale.product_sale_items.each do |sale_item|
          has_loc = hash_locs[sale_item.feature_item_id]
          if has_loc.present?
            has_loc.update_column(:quantity, has_loc.quantity + sale_item.quantity)
          else

            product_locations = ProductLocation.get_quantity(feature_item_id)
            quantity = 0
            is_added = false
            item_quantity = sale_item.quantity
            product_locations.each {|loc|
              if quantity < item_quantity
                q = if loc.quantity >= (item_quantity - quantity)
                      item_quantity - quantity
                    else
                      loc['quantity'].to_i
                    end
                quantity += q
                ProductWarehouseLoc.create(salesman_travel_id: salesman_travel_id,
                                           product_id: sale_item.product_id,
                                           location_id: loc.id,
                                           feature_item_id: sale_item.feature_item_id,
                                           quantity: q)
                is_added = true
              else
                break
              end
            }
            unless is_added
              ProductWarehouseLoc.create(salesman_travel_id: salesman_travel_id,
                                         product_id: sale_item.product_id,
                                         location_id: 1,
                                         feature_item_id: sale_item.feature_item_id,
                                         quantity: item_quantity)
            end
          end
        end
        render json: {success: true}
      else
        render json: {success: false, errors: travel_route.errors.full_messages}
      end
    end
  end

  def edit
    # unless (can? :manage, SalesmanTravel) && !@salesman_travel.load_at.present?
    redirect_to action: :show, id: @salesman_travel.id
    # end
  end

  def update
    @salesman_travel.attributes = travel_update_params
    @salesman_travel.salesman_travel_routes.each do |route|
      route.location_id = route.product_sale.location_id
    end
    if @salesman_travel.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      logger.info("ERRORS: #{@salesman_travel.errors.full_messages}")
      render 'edit'
    end
  end

  def destroy
    redirect_to action: :index
    # if (can? :manage, SalesmanTravel) && !@salesman_travel.load_at.present?
    #   @salesman_travel.salesman_travel_routes.each do |route|
    #     route.is_update = true
    #   end
    #   @salesman_travel.destroy!
    #   flash[:success] = t('alert.deleted_successfully')
    #   redirect_to action: :index
    # else
    #   redirect_to action: :show, id: @salesman_travel.id
    # end
  end

  private

  def set_salesman_travel
    @salesman_travel = SalesmanTravel.find(params[:id])
  end

  def salesman_travel_params
    params.require(:salesman_travel).permit(:sale_ids, :zone_ids, :allocation, :salesman_id, :description)
  end

  def travel_update_params
    params.require(:salesman_travel).permit(:salesman_id, :description,
                                            salesman_travel_routes_attributes: [:id, :queue, :product_sale_id, :is_update, :_destroy])
  end
end
