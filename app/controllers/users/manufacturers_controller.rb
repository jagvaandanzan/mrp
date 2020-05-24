class Users::ManufacturersController < Users::BaseController
  load_and_authorize_resource
  before_action :set_manufacturer, only: [:edit, :update, :destroy]

  def index
    @country = params[:country]
    @manufacturers = Manufacturer.search(@country).page(params[:page])
    cookies[:manufacturer_page_number] = params[:page]
  end

  def new
    @manufacturer = Manufacturer.new
  end

  def create
    @manufacturer = Manufacturer.new(manufacturer_params)

    if @manufacturer.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @manufacturer.attributes = manufacturer_params
    if @manufacturer.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @manufacturer.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:id])
  end

  def manufacturer_params
    params.require(:manufacturer).permit(:country)
  end
end
