class Operators::ProductSaleCallsController < Operators::BaseController
  before_action :set_sale_call, only: [:edit, :update, :destroy]

  def index
    @start = params[:start]
    @finish = params[:finish]
    @phone = params[:phone]
    @product_name = params[:product_name]

    @sale_calls = ProductSaleCall.search(@start, @finish, @phone, @product_name).page(params[:page])
  end

  def new
    @sale_call = ProductSaleCall.new
    @sale_call.quantity = 1
  end

  def create
    @sale_call = ProductSaleCall.new(sale_call_params)

    if @sale_call.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
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
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def get_product_balance
    product_balance = ProductBalance.balance(params[:product_id])
    render json: {balance: product_balance}
  end

  private

  def set_sale_call
    @sale_call = ProductSaleCall.find(params[:id])
  end

  def sale_call_params
    params.require(:product_sale_call)
        .permit(:phone, :code, :quantity, :message)
        .merge(operator: current_operator)
  end
end
