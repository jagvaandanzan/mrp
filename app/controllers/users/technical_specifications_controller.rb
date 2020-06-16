class Users::TechnicalSpecificationsController < Users::BaseController
  before_action :set_specification, only: [:edit, :update, :destroy]

  def index
    @name = params[:name]
    @specifications = TechnicalSpecification.search(@name).page(params[:page])
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
    params.require(:technical_specification).permit(:specification_gr,
                                                    technical_spec_items_attributes: [:id, :specification, :_destroy])
  end
end
