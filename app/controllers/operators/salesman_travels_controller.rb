class Operators::SalesmanTravelsController < Operators::BaseController
  load_and_authorize_resource only: [:index, :new, :map, :zone, :edit, :update]
  before_action :set_salesman_travel, only: [:show, :edit, :update, :destroy]

  def index
    today = Time.current.beginning_of_day
    @start = params[:start].presence || today.strftime("%Y/%m/%d")
    @finish = params[:finish].presence || today.strftime("%Y/%m/%d")

    @salesman_travels = SalesmanTravel.search(DateTime.parse(@start),DateTime.parse(@finish))
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

    respond_to do |format|
      format.js {
        render 'operators/salesman_travels/get_salesman', locals: {hide_modal: save_action}
      }
    end
  end

  def show
  end

  def edit
    unless (can? :manage, SalesmanTravel) && !@salesman_travel.load_at.present?
      redirect_to action: :show, id: @salesman_travel.id
    end
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
    if (can? :manage, SalesmanTravel) && !@salesman_travel.load_at.present?
      @salesman_travel.salesman_travel_routes.each do |route|
        route.is_update = true
      end
      @salesman_travel.destroy!
      flash[:success] = t('alert.deleted_successfully')
      redirect_to action: :index
    else
      redirect_to action: :show, id: @salesman_travel.id
    end
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
