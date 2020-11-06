class Operators::ProductSaleCallsController < Operators::BaseController
  before_action :set_sale_call, only: [:edit, :update, :show, :destroy]

  def index
    @start = params[:start]
    @finish = params[:finish]
    @product_name = params[:product_name]
    @phone = params[:phone]
    @status = params[:status]
    cookies[:product_sale_call_page_number] = params[:page]
    @sale_calls = if @status.present?
                    ProductSaleCall.search(@start, @finish, @phone, @product_name, @status).page(params[:page])
                  else
                    ProductSaleCall.by_status_not_ids([3, 7, 8])
                        .search(@start, @finish, @phone, @product_name, @status).page(params[:page])
                  end
  end

  def new
    @sale_call = ProductSaleCall.new
    @sale_call.is_web = true
  end

  def edit
    @sale_call.is_web = true
  end

  def destroy
    @sale_call.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end


  def update
    @sale_call.attributes = sale_call_params

    if @sale_call.save
      flash[:success] = t('alert.info_updated')

      if @sale_call.status_id == 3 # Захиалга
        redirect_to new_operators_product_sale_path(sale_call_id: @sale_call.id)
      else
        redirect_to action: 'index'
      end
    else
      render 'edit'
    end
  end

  def show
  end

  def auto_save
    if params[:phone].present?
      sale_call = if params[:id].present?
                    ProductSaleCall.find(params[:id])
                  else
                    ProductSaleCall.new(status_id: 2)
                  end
      sale_call.is_web = true
      sale_call.operator = current_operator
      sale_call.phone = params[:phone]
      sale_call.status_id = params[:status_id] if params[:status_id].present?
      sale_call.save(validate: false)

      render json: {id: sale_call.id}
    else
      render json: {id: 0}
    end
  end

  def get_prev_sales
    @product_sales = ProductSale.search(nil, nil, nil, params[:phone], nil).first(5)
    @sale_calls = ProductSaleCall.search(nil, nil, params[:phone], nil, nil)
                      .by_not_id(params[:id])
                      .by_status_not_ids([1, 2]).first(5)

    respond_to do |format|
      format.js {render 'previous_sales'}
    end
  end

  private

  def set_sale_call
    @sale_call = ProductSaleCall.find(params[:id])
  end

  def sale_call_params
    params.require(:product_sale_call)
        .permit(:id, :is_web, :phone, :status_id, :status_sub_id, :sum_price, :message,
                product_call_items_attributes: [:id, :product_id, :feature_item_id, :quantity, :price, :sum_price, :remainder, :_destroy])
        .merge(operator: current_operator)
  end
end
