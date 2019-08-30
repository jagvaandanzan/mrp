class Users::LocKhoroosController < Users::BaseController
  before_action :set_loc_khoroo, only: [:edit, :update, :destroy]

  def index
    @search_name = params[:loc_khoroo_name]
    @loc_district = LocDistrict.find_by!(id: params[:id])
    @loc_khoroos = LocKhoroo.search(@loc_district.id, @search_name).page(params[:page])
  end

  def new
    @loc_khoroo = LocKhoroo.new
    @loc_khoroo.loc_district = LocDistrict.find_by!(id: params[:id])
  end

  def create
    @loc_khoroo = LocKhoroo.new(loc_khoroo_params)
    if @loc_khoroo.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index', id: @loc_khoroo.loc_district_id
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @loc_khoroo.attributes = loc_khoroo_params
    if @loc_khoroo.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, id: @loc_khoroo.loc_district_id
    else
      render 'edit'
    end
  end

  def destroy
    @loc_khoroo.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index', id: @loc_khoroo.loc_district_id
  end

  private

  def set_loc_khoroo
    @loc_khoroo = LocKhoroo.find(params[:id])
  end

  def loc_khoroo_params
    params.require(:loc_khoroo).permit(:loc_district_id, :name)
  end
end
