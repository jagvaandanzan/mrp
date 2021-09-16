class Users::ProductReportsController < Users::BaseController

  def track
    @code = params[:code]
    @name = params[:name]
    @customer_id = params[:customer_id]
    @salesman_id = params[:salesman_id]
    @balance = params[:balance]

    today = Time.current.beginning_of_day
    @by_start = params[:by_start].presence || (today - 10.days).strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || today.strftime("%Y/%m/%d")

    @category_id = params[:category_id]
    if @category_id.present?
      @product_category = ProductCategory.find(@category_id)
      @headers = ApplicationController.helpers.get_category_parents(@product_category)
      @headers = @headers.reverse
    end

    feature_items = ProductFeatureItem
                        .join_products
                        .join_balances
                        .s_by_code(@code)
                        .s_by_name(@name)
                        .by_customer(@customer_id)
                        .by_category(@category_id)
                        .by_balance(@balance)
                        .by_balance_date(@by_start.to_date, @by_end.to_date)
                        .by_salesman(@salesman_id)
                        .order_is_feature
    @feature_items = feature_items.page(params[:page])
    all_c = feature_items.count.count
    @total_page = (all_c / 25) + (all_c % 25 > 0 ? 1 : 0)
    cookies[:product_track_page_number] = params[:page]
  end

  def track_logs
    @by_start = params[:by_start].to_date
    @by_end = params[:by_end].to_date
    @product = Product.find(params[:product_id])
    @feature_item = ProductFeatureItem.find(params[:id])
    @product_balances = ProductBalance.by_feature_id(params[:id], @by_start, @by_end)
  end

  def track_log
    @product = Product.find(params[:product_id])
    @feature_item = ProductFeatureItem.find(params[:id])
    @by_start = params[:by_start].to_date
    @by_end = params[:by_end].to_date
    @product_balances = ProductBalance.by_feature_id(params[:id], @by_start, @by_end)
    respond_to do |format|
      format.js {render 'users/product_reports/track_log_ajax'}
    end
  end

end
