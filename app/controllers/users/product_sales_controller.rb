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

end
