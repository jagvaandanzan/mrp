class Users::ProductIncomeItemsController < Users::BaseController
  before_action :set_product_income_item, only: [:edit, :update, :destroy, :show]

  def index
    @search_name = params[:product_name]
    @search_code = params[:supply_code]
    @search_type = params[:search_type]
    @income = ProductIncome.find_by!(id: params[:income_id])
    @items = ProductIncomeItem.search(@income.id, @search_name, @search_code, @search_type).page(params[:page])
  end

  def new
    @item = ProductIncomeItem.new
    @item.income = ProductIncome.find_by!(id: params[:income_id])
  end

  def create
    @item = ProductIncomeItem.new(product_income_item_params)
    if @item.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, income_id: @item.income.id
    else
      Rails.logger.debug(@item.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @headers = ApplicationController.helpers.get_category_parents(@item.location)
    @headers = @headers.reverse()
  end

  def update
    @item.attributes = product_income_item_params
    if @item.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index', income_id: @item.income.id
    else
      render 'edit'
    end
  end

  def destroy
    @income_id = @item.income.id

    @item.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, income_id: @income_id
  end


  def get_location_children
    @locations = nil
    if params[:parent_id].present?
      @locations =  ProductLocation.search(params[:parent_id])
    end

    render json: {childrens: @locations}
  end

  def get_supply_order_info
    @supply_order_item = nil
    if params[:order_item_id].present?
      @supply_order_item =  ProductSupplyOrderItem.find_by!(id: params[:order_item_id])
    end

    if @supply_order_item.present?
      render json: {order_code: @supply_order_item.supply_order.code,
                    exchange: @supply_order_item.supply_order.exchange_i18n,
                    exchange_value: @supply_order_item.supply_order.exchange_value}
    else
      render json: {}
    end
  end

  private

  def set_product_income_item
    @item = ProductIncomeItem.find(params[:id])
  end

  def product_income_item_params
    params.require(:product_income_item).permit(:income_id, :supply_order_item_id, :location_id, :quantity, :price, :shuudan, :note, :urgent_type,
                                                income_feature_rels_attributes: [:id, :feature_option_id, :_destroy])
  end
end
