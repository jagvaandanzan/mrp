class Operators::DistributingController < Operators::BaseController
  authorize_resource class: false, only: [:index, :add_product_sale, :change_route_queue, :remove_route, :distributing]

  def index
    if can? :manage, :distributing
      @today = Time.now.beginning_of_day
      @date = if params[:date].present?
                params[:date].to_time
              else
                @today
              end
      # @date = @date.change(day: 8)
      # @salesman_id = 1
    else
      redirect_to operators_root_path
    end

  end

  def salesman_track
    ids = SalesmanTrack.by_date(Time.now.beginning_of_day).map(&:id).to_a
    @salesman_tracks = SalesmanTrack.by_ids(ids)
    respond_to do |format|
      format.js {render 'operators/distributing/salesman_tracks_ajax'}
    end
  end

  def set_travel
    @salesman_travels = SalesmanTravel.by_salesman(params[:salesman_id])
                            .by_date(params[:date].to_time)
    respond_to do |format|
      format.js {render 'operators/distributing/travels_ajax'}
    end
  end

  # Хүргэлтүүд
  def travel_routes
    @travel_routes = SalesmanTravelRoute
                         .by_travel_id(params[:travel_id])
                         .order_queue
    respond_to do |format|
      format.js {render 'operators/distributing/travel_routes_ajax'}
    end
  end

  # Хувиарлагдаагүй бараанууд
  def product_sales
    @product_sales = ProductSale.by_salesman_nil
    respond_to do |format|
      format.js {render 'operators/distributing/product_sales_ajax'}
    end
  end

  def add_product_sale
    if can? :manage, :distributing
      queue = params[:queue].to_i - 1
      SalesmanTravelRoute.after_queue(queue)
          .nil_delivered_at
          .order_queue.each {|route|
        route.update_column(:queue, route.queue + 1)
      }
      product_sale = ProductSale.find(params[:id])

      travel_route = SalesmanTravelRoute.new
      travel_route.queue = queue
      travel_route.distance = 0
      travel_route.duration = 0
      travel_route.salesman_travel_id = params[:travel_id]
      travel_route.location = product_sale.location
      travel_route.product_sale = product_sale
      travel_route.save
      product_sale.update_column(:salesman_travel_id, params[:travel_id])

      @travel_routes = SalesmanTravelRoute
                           .by_travel_id(params[:travel_id])
                           .order_queue
      @product_sale_id = params[:id]
      respond_to do |format|
        format.js {render 'operators/distributing/travel_routes_ajax'}
      end
    else
      redirect_to operators_root_path
    end
  end

  def change_route_queue
    travel_route = SalesmanTravelRoute.find(params[:route_id])
    travel_route.update_column(:queue, params[:queue].to_i - 1)

    @travel_routes = SalesmanTravelRoute
                         .by_travel_id(travel_route.salesman_travel_id)
                         .order_queue
    respond_to do |format|
      format.js {render 'operators/distributing/travel_routes_ajax'}
    end
  end

  def remove_route
    if can? :manage, :distributing
      travel_route = SalesmanTravelRoute.find(params[:route_id])
      travel_route.product_sale.update_column(:salesman_travel_id, nil)
      travel_route.really_destroy!

      @travel_routes = SalesmanTravelRoute
                           .by_travel_id(travel_route.salesman_travel_id)
                           .order_queue
      respond_to do |format|
        format.js {render 'operators/distributing/travel_routes_ajax'}
      end
    else
      redirect_to operators_root_path
    end
  end

  def distributing
    if can? :manage, :distributing
      d = Distribute.instance
      salesman = Salesman.find(params[:salesman_id])
      status, message, travel = d.create(salesman)
      if status == 201
        @travel_routes = SalesmanTravelRoute
                             .by_travel_id(travel.id)
                             .order_queue

        @salesman_travels = SalesmanTravel.by_salesman(params[:salesman_id])
                                .by_date(Time.now.beginning_of_day)
        @travel_selected = travel.id
        respond_to do |format|
          format.js {render 'operators/distributing/travel_routes_ajax'}
        end
      else
        render json: {status: status, message: message}
      end
    else
      redirect_to operators_root_path
    end
  end
end