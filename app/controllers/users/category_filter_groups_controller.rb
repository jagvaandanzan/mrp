class Users::CategoryFilterGroupsController < Users::BaseController
  authorize_resource
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy]

  def index
    @filter_name = params[:filter_name]
    @filter_groups = CategoryFilterGroup.search(@filter_name).page(params[:page])
    cookies[:category_filter_page_number] = params[:page]
  end

  def new
    @filter_group = CategoryFilterGroup.new
  end

  def create
    @filter_group = CategoryFilterGroup.new(filter_group_params)
    if @filter_group.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      logger.debug(@filter_group.errors.full_messages)
      render 'new'
    end
  end

  def edit
  end

  def show
  end

  def update
    @filter_group.attributes = filter_group_params
    @filter_group.prod = true
    if @filter_group.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @filter_group.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_filter_group
    @filter_group = CategoryFilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:category_filter_group).permit(:name,
                                                  category_filters_attributes: [:id, :name, :_destroy])
  end
end
