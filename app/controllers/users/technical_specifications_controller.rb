class Users::TechnicalSpecificationsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_specification, only: [:edit, :update, :destroy]

  def index
    @specification = params[:specification]
    @specifications = TechnicalSpecification.search(@specification).page(params[:page])
    cookies[:specification_page_number] = params[:page]
  end

  def new
    @specification = TechnicalSpecification.new
  end

  def create
    @specification = TechnicalSpecification.new(specification_params)

    if @specification.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @specification.attributes = specification_params
    if @specification.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @specification.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_specification
    @specification = TechnicalSpecification.find(params[:id])
  end

  def specification_params
    params.require(:specification).permit(:specification)
  end
end
