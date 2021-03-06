class Users::DeliveryReportsController < Users::BaseController
  authorize_resource class: false

  def index
    @salesman_id = params[:salesman_id]
    @date = if params[:date].present?
              params[:date].to_date
            else
              Time.current.beginning_of_day
            end

    travers = SalesmanTravel.travels(@salesman_id, @date)

    @product_sales = ProductSale.by_travel_ids(travers.map(&:id).to_a)
                         .by_delivered
                         .order(:phone)
    @sale_directs = ProductSaleDirect.by_salesman_id(@salesman_id)
                        .date_between(@date)
                        .order(:phone)
  end

  def salary
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @salesman_id = params[:salesman_id]
    today = Time.current.beginning_of_day
    @by_start = today.strftime("%Y/%m/%d") unless @by_start.present?
    @by_end = today.strftime("%Y/%m/%d") unless @by_end.present?

    if @salesman_id.present?
      @travel_routes = SalesmanTravelRoute.not_ni_wage
                           .search(@by_start.to_date, @by_end.to_date, params[:salesman_id])
    end

  end

end
