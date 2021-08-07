class Operators::LocationZonesController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_location_zone, only: [:edit, :show, :update, :destroy]

  def index
    @search_name = params[:search_name]
    @location_zones = LocationZone.search(@search_name).page(params[:page])
    cookies[:location_zone_page_number] = params[:page]
  end

  def new
    @location_zone = LocationZone.new
    @location_zone.queue = LocationZone.all.count + 1
    if @location_zone.queue > 1
      last_zone = LocationZone.order_queue.last
      @location_zone.lat_l_t = last_zone.lat_r_t
      @location_zone.lng_l_t = last_zone.lng_r_t
      @location_zone.lat_l_b = last_zone.lat_r_b
      @location_zone.lng_l_b = last_zone.lng_r_b
      @location_zone.lat_r_t = last_zone.lat_r_t
      @location_zone.lng_r_t = last_zone.lng_r_t + 0.001
      @location_zone.lat_r_b = last_zone.lat_r_b
      @location_zone.lng_r_b = last_zone.lng_r_b + 0.001
    else
      @location_zone.lat_l_t = 47.919316
      @location_zone.lng_l_t = 106.916274
      @location_zone.lat_l_b = 47.918223
      @location_zone.lng_l_b = 106.916274
      @location_zone.lat_r_t = 47.919316
      @location_zone.lng_r_t = 106.919
      @location_zone.lat_r_b = 47.918223
      @location_zone.lng_r_b = 106.919
    end
  end

  def create
    @location_zone = LocationZone.new(location_zone_params)

    if @location_zone.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @location_zone.attributes = location_zone_params
    if @location_zone.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @location_zone.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_location_zone
    @location_zone = LocationZone.find(params[:id])
  end

  def location_zone_params
    params.require(:location_zone)
        .permit(:queue, :name, :lat_l_t, :lng_l_t, :lat_l_b, :lng_l_b, :lat_r_t, :lng_r_t, :lat_r_b, :lng_r_b)
  end
end
