class Users::SupplyCalculationsController < Users::BaseController

  def supply_orders
    logistic = Logistic.find(1)
    @balance = logistic.balance
    month_1 = Time.current.beginning_of_month
    @by_start = params[:by_start].presence || month_1.strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || (month_1 + 1.month).strftime("%Y/%m/%d")

  end

end
