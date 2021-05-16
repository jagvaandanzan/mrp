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
        render json: { success: true, name: json['name'] }
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end
  end

  def tax

  end

  def report
    @opers = ProductSaleStatus.by_type("oper")
    @sales = ProductSaleStatus.by_type("sals")
    @others = ProductSaleStatus.not_types(['oper', 'sals'])
  end

  def excel
    puts "params = #{params}"
  end
end
