class Users::BrandsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_brand, only: [:edit, :update, :destroy]

  def index
    @sname = params[:name]
    @brands = Brand.search(@sname).page(params[:page])
    cookies[:brand_page_number] = params[:page]
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)

    if @brand.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @brand.attributes = brand_params
    if @brand.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @brand.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name, :logo, :description)
  end
end
