class Operators::LocationsController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_location, only: [:edit, :show, :update, :destroy]

  def index
    @search_name = params[:location_name]
    @loc_khoroo = LocKhoroo.find_by!(id: params[:id])
    @locations = Location.search(@loc_khoroo.id, @search_name).page(params[:page])
    cookies[:location_page_number] = params[:page]
  end

  def new
    @location = Location.new
    @location.loc_khoroo = LocKhoroo.find_by!(id: params[:id])
    @location.loc_district_id = @location.loc_khoroo.loc_district_id

    loo = Location.where(operator: current_operator)

    if loo.present?
      location_last = loo.last
      @location.latitude = location_last.latitude
      @location.longitude = location_last.longitude
    else
      @location.latitude = 47.918772
      @location.longitude = 106.917609
    end

  end

  def create
    @location = Location.new(location_params)

    if @location.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, id: @location.loc_khoroo_id
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update

    @location.attributes = location_params
    if @location.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, id: @location.loc_khoroo_id, page: cookies[:location_page_number]
      # redirect_to :action => 'show', id: @location.id
    else
      render 'edit'
    end
  end

  def destroy
    @location.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, id: @location.loc_khoroo_id
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location)
        .permit(:loc_district_id, :loc_khoroo_id, :micro_region, :town, :street, :apartment, :entrance, :name, :name_la, :station_id, :distance, :latitude, :longitude)
        .merge(:operator => current_operator)
  end
end
