class Users::ProductReportsController < Users::BaseController

  def track
    @code = params[:code]
    @name = params[:name]
    @customer_id = params[:customer_id]
    @salesman_id = params[:salesman_id]
    @balance = params[:balance]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @category_id = params[:category_id]
    if @category_id.present?
      @product_category = ProductCategory.find(@category_id)
      @headers = ApplicationController.helpers.get_category_parents(@product_category)
      @headers = @headers.reverse
    end

    @feature_items = ProductFeatureItem.join_products
                         .join_balances
                         .s_by_code(@code)
                         .s_by_name(@name)
                         .by_customer(@customer_id)
                         .by_category(@category_id)
                         .by_balance(@balance)
                          .by_balance_date(@by_start, @by_end)
                         .order_is_feature

  end

end
