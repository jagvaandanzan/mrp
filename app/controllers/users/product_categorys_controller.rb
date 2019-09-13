class Users::ProductCategorysController < Users::BaseController
  before_action :setCategory, only: [:edit, :update, :destroy]

  def index
    @parent = nil
    @categories = nil
    # = ProductCategory.find_by!(id: params[:parent_id])
    puts(params)
    if !params[:parent_id].nil?
      @parent = ProductCategory.find_by!(id: params[:parent_id])
      @categories = ProductCategory.search(@parent.id).page(params[:page])
    else
      @categories = ProductCategory.top_level().page(params[:page])
    end
  end

  def new
    @category = ProductCategory.new
    if !params[:parent_id].nil?
      @category.parent = ProductCategory.find_by!(id: params[:parent_id])
    else
      @category.parent = nil
    end
  end

  def create
    @category = ProductCategory.new(category_params)

    if @category.save
      flash[:success] = t('alert.saved_successfully')

      redirect_to action: :index, parent_id: !@category.parent.nil? ? @category.parent.id : nil
    else
      # Rails.logger.info(@category.errors.inspect)
      render 'new'
    end
  end

  def edit
  end

  def update
    @parent_id = !@category.parent.nil? ? @category.parent.id : nil
    @category.attributes = category_params
    if @category.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, parent_id: @parent_id
    else
      # Rails.logger.info(@category.errors.inspect)
      render 'edit'
    end
  end

  def destroy
    @parent_id = !@category.parent.nil? ? @category.parent.id : nil
    @category.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, parent_id: @parent_id
  end

  private

  def setCategory
    @category = ProductCategory.find(params[:id])
  end
  def category_params
    params.require(:product_category)
        .permit(:parent_id, :name, :code)
  end
end
