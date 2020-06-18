class Users::CategoryFilterGroupsController < Users::BaseController
  authorize_resource
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy]

  def index
    @category_id = params[:category_id]
    @category_code = params[:category_code]
    @category_name = params[:category_name]
    @filter_name = params[:filter_name]
    @filter_groups = CategoryFilterGroup.search(@category_id, @category_code, @category_name, @filter_name).page(params[:page])
    cookies[:category_filter_page_number] = params[:page]
  end

  def new
    product_category = ProductCategory.find(params[:category_id])
    @filter_group = CategoryFilterGroup.new(product_category: product_category)
  end

  def create
    @filter_group = CategoryFilterGroup.new(filter_group_params)
    if @filter_group.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index', category_id: @filter_group.product_category_id
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
    if @filter_group.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index', category_id: @filter_group.product_category_id
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
    params.require(:category_filter_group).permit(:product_category_id, :name, :name_en,
                                                  category_filters_attributes: [:id, :name, :name_en, :img, :_destroy])
  end
end
