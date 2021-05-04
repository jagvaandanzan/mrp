class Users::CustomerWarehousesController < Users::BaseController
  before_action :set_warehouse, only: [:edit, :update, :destroy]

  def new
    @warehouse = CustomerWarehouse.new
    @warehouse.customer_id = params[:customer_id]
    @warehouse.latitude = 47.918772
    @warehouse.longitude = 106.917609
  end

  def create
    @warehouse = CustomerWarehouse.new(warehouse_params)
    if @warehouse.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to users_customer_path(@warehouse.customer)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @warehouse.attributes = warehouse_params
    if @warehouse.save
      flash[:success] = t('alert.info_updated')
      redirect_to users_customer_path(@warehouse.customer)
    else
      render 'edit'
    end
  end

  def destroy
    @warehouse.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to users_customer_path(@warehouse.customer)
  end

  private

  def set_warehouse
    @warehouse = CustomerWarehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:customer_warehouse).permit(:customer_id, :name, :description,
                                               :mo_start, :mo_end,
                                               :tu_start, :tu_end,
                                               :we_start, :we_end,
                                               :th_start, :th_end,
                                               :fr_start, :fr_end,
                                               :sa_start, :sa_end,
                                               :su_start, :su_end,
                                               :latitude, :longitude)
  end
end
