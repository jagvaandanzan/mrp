class Users::ProductSalesController < Users::BaseController

  def index
    @product_name = params[:product_name]
    @status_id = params[:status_id]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]
    @send_tax = params[:send_tax]
    cookies[:product_sale_page_number] = params[:page]
    @product_sales = ProductSale.by_tax
                         .search(@product_name, @start, @finish, @phone, @status_id)
                         .send_tax(@send_tax)
                         .page(params[:page])
  end

  def check_register
    if params[:register].to_s.length == 7

      response = ApplicationController.helpers.sent_market_web("http://info.ebarimt.mn/rest/merchant/info?regno=#{params[:register]}", 'get', nil)
      json = JSON.parse(response.body)
      if response.code.to_i == 200 && json['name'].present?
        render json: {success: true, name: json['name']}
      else
        render json: {success: false}
      end
    else
      render json: {success: false}
    end
  end

  def tax

  end

  def report
    if params[:start].present?
      @start = params[:start]
      @finish = params[:finish]
    else
      today = Time.now.beginning_of_month - 2.months
      @start = today.strftime('%Y/%m/%d')
      @finish = Time.now.strftime('%Y/%m/%d')
    end
    if params[:list_type].present?
      @list_type = params[:list_type].to_i
    else
      1
    end
    @salesman_id = params[:salesman_id]
    @operator_id = params[:operator_id]
    @product_code = params[:product_code]
    @customer_id = params[:customer_id]
    @order_0 = params[:order_0]
    @order_1 = params[:order_1]
    @order_2 = params[:order_2]
    @order_3 = params[:order_3]
    @status_ids = params[:status_ids].map(&:to_i) if params[:status_ids].present?
    @sales = ProductSale.report_excel(@start, @finish, @salesman_id, @operator_id, @product_code, @customer_id, @order_0, @order_1, @order_2, @order_3, @status_ids)
    @product_sales = @sales.page(params[:page])
    respond_to do |format|
      format.xlsx {
        response.headers[
            'Content-Disposition'
        ] = "attachment; filename=" + "Борлуулалтын тайлан" + ".xlsx"
      }
      format.html {render :report}
    end
  end
end
