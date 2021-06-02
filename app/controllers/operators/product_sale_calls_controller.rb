class Operators::ProductSaleCallsController < Operators::BaseController
  before_action :set_sale_call, only: [:edit, :update, :show, :destroy]

  def index
    current_operator.clear_active_call
    @start = params[:start]
    @finish = params[:finish]
    @product_name = params[:product_name]
    @phone = params[:phone]
    @status_id = params[:status_id]
    @status = params[:status]
    @status_sub = params[:status_sub]
    cookies[:product_sale_call_page_number] = params[:page]

    status_ids = nil
    if @status.present?
      status = ProductSaleStatus.find(@status)
      if status.next.present?
        status_ids = status.next.split(",").map(&:to_i)
      end
    end

    @sale_calls = if @status_id.present?
                    ProductSaleCall.search(@start, @finish, @phone, @product_name, @status_id, status_ids).page(params[:page])
                  else
                    ProductSaleCall.by_not_status('call_order')
                        .search(@start, @finish, @phone, @product_name, @status_id, status_ids).page(params[:page])
                  end
  end

  def new
    @sale_call = ProductSaleCall.new
    @sale_call.is_web = true
  end

  def edit
    @sale_call.is_web = true
    @sale_call.set_statuses
    operator_id = current_operator.id
    if @sale_call.active_opr_id.present?
      if operator_id != @sale_call.active_opr_id
        flash[:alert] = "#{@sale_call.active_opr.name} орсон байна!"
        redirect_to action: 'index'
      end
    else
      @sale_call.update_column(:active_opr_id, operator_id)
    end
  end

  def destroy
    @sale_call.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def update
    status_id_was = @sale_call.status_id
    @sale_call.attributes = sale_call_params

    if @sale_call.save
      flash[:success] = t('alert.info_updated')

      if @sale_call.status.alias == 'call_order' # Захиалга
        if @sale_call.product_sale.present?
          redirect_to edit_operators_product_sale_path(@sale_call.product_sale)
        else
          @sale_call.update_column(:status_id, status_id_was)
          redirect_to new_operators_product_sale_path(sale_call_id: @sale_call.id)
        end
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
                    sale = ProductSaleCall.by_status("call_no_finish")
                               .by_phone(params[:phone])
                               .by_operator_id(current_operator.id)
                    status = ProductSaleStatus.find_by_alias("call_no_finish")
                    sale.present? ? sale.first : ProductSaleCall.new(status: status, source: 1)
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
                      .first(5)

    respond_to do |format|
      format.js {render 'previous_sales'}
    end
  end

  def check_sale_order
    product_sale = ProductSale.search(nil, nil, nil, params[:phone], "oper_confirmed").first(1)
    render json: {is_ordered: product_sale.present?}
  end

  private

  def set_sale_call
    @sale_call = ProductSaleCall.find(params[:id])
  end

  def sale_call_params
    params.require(:product_sale_call)
        .permit(:id, :source, :is_web, :phone, :status_id, :status_m, :status_sub, :sum_price, :message,
                product_call_items_attributes: [:id, :product_id, :feature_item_id, :quantity, :price, :sum_price, :remainder, :_destroy])
        .merge(operator: current_operator)
  end
end
