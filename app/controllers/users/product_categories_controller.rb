class Users::ProductCategoriesController < Users::BaseController
  # load_and_authorize_resource
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @parent = nil
    @categories = nil
    # = ProductCategory.find_by!(id: params[:parent_id])
    if params[:parent_id].nil?
      @categories = ProductCategory.top_level.page(params[:page])
    else
      @parent = ProductCategory.find_by!(id: params[:parent_id])
      @categories = ProductCategory.search(@parent.id).page(params[:page])
    end
  end

  def new
    @category = ProductCategory.new
    @category.code = ApplicationController.helpers.get_code(ProductCategory.last)
    @category.parent = params[:parent_id].present? ? ProductCategory.find_by!(id: params[:parent_id]) : nil
  end

  def create
    @category = ProductCategory.new(category_params)

    if @category.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, parent_id: @category.parent_id
    else
      # Rails.logger.info(@category.errors.inspect)
      render 'new'
    end
  end

  def edit
    @cross_headers = ApplicationController.helpers.get_category_parents(@category.cross).reverse if @category.cross_id.present?
    @parent_headers = ApplicationController.helpers.get_category_parents(@category.parent).reverse if @category.parent_id.present?
  end

  def update
    @category.attributes = category_params
    if @category.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, parent_id: @category.parent_id
    else
      render 'edit'
    end
  end

  def destroy
    @parent_id = @category.parent_id
    @category.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, parent_id: @parent_id
  end

  private

  def set_category
    @category = ProductCategory.find(params[:id])
  end

  def category_params
    params.require(:product_category).permit(:parent_id, :image, :queue, :name, :name_en, :is_clothes, :code, :cross_id)
  end
end
