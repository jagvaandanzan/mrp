class Users::LocDistrictsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_loc_district, only: [:edit, :update, :destroy]

  def index
    @loc_districts = LocDistrict.all.page(params[:page]).order(:name)
    ActionCable.server.broadcast 'fb_comment_channel', content: '112'
  end

  def new
    @loc_district = LocDistrict.new
  end

  def create
    @loc_district = LocDistrict.new(loc_district_params)

    if @loc_district.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update

    @loc_district.attributes = loc_district_params
    if @loc_district.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @loc_district.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_loc_district
    @loc_district = LocDistrict.find(params[:id])
  end

  def loc_district_params
    params.require(:loc_district)
        .permit(:name)
  end
end
