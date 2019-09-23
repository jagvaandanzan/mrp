class Users::ProductLocationsController < Users::BaseController
  before_action :setLocation, only: [:edit, :update, :destroy]

  def index
    @parent = params[:parent_id].present? ? ProductLocation.find_by!(id: params[:parent_id]) : nil
    @locations = ProductLocation.search(params[:parent_id]).page(params[:page])
  end

  def new
    @location = ProductLocation.new
    @location.code = ApplicationController.helpers.get_code(ProductLocation.last)
    @location.parent = params[:parent_id].present? ? ProductLocation.find_by!(id: params[:parent_id]) : nil
  end

  def create
    @location = ProductLocation.new(location_params)

    if @location.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, parent_id: @location.parent_id
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @location.attributes = location_params
    if @location.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, parent_id: @location.parent_id
    else
      render 'edit'
    end
  end

  def destroy
    @parent_id = @location.parent_id
    @location.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, parent_id: @parent_id
  end

  private

  def setLocation
    @location = ProductLocation.find(params[:id])
  end
  def location_params
    params.require(:product_location)
        .permit(:parent_id, :name, :code)
  end
end
