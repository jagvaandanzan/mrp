class Users::CustomerImportsController < Users::BaseController

  def new
    @customer_import = CustomerImport.new
  end

  def create
    @customer_import = CustomerImport.new(import_params)
    if @customer_import.valid? && @customer_import.valid
      flash[:success] = "#{@customer_import.save} ширхэг бараа амжилттай хадгаллаа."
      redirect_to balance_users_product_feature_items_path(customer_id: @customer_import.customer_id)
    else
      render 'new'
    end
  end

  def customer_warehouse
    @list = CustomerWarehouse.by_customer_id(params[:id])
    @select_id = 'customer_import_warehouse_id'

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

  private

  def import_params
    params.require(:customer_import).permit(:customer_id, :warehouse_id, :file)
  end
end
