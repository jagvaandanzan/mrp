class Users::WarehouseReportsController < Users::BaseController
  authorize_resource class: false

  def daily
    today = Time.current.beginning_of_day
    @by_start = params[:by_start].presence || today.strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || today.strftime("%Y/%m/%d")

    @start_date = DateTime.parse(@by_start)
    @end_date = DateTime.parse(@by_end) + 1.days

    @salesmen = Salesman
                    .joins(:product_sale_status_logs)
                    .where('salesman_travels.created_at >= ?', @start_date)
                    .where('salesman_travels.created_at < ?', @end_date)
                    .where("product_sale_status_logs.status_id = ?", 10)
                    .group("salesmen.id")
  end

  def products
    t = params[:t].to_i
    all_items = ProductSaleItem.where("product_sale_items.product_sale_id IN (?)", params[:sale_ids])
    @product_sale_items = case t
                          when 1
                            all_items.where("bought_quantity IS NOT ?", nil)
                          when 2
                            all_items.where("back_quantity IS NOT ?", nil)
                          when 3
                            all_items
                                .joins(:product_sale_status_logs)
                                .where("28 <= product_sale_status_logs.status_id AND product_sale_status_logs.status_id <= 30")
                                .where("product_sales.status_id = ?", 35)
                                .where("back_quantity IS NOT ?", nil)
                          when 4
                            all_items
                                .joins(:product_sale_returns)
                                .where("product_sale_returns.id IS NOT ?", nil)
                                .where("back_quantity IS NOT ?", nil)
                          else
                            all_items
                          end
  end
end
