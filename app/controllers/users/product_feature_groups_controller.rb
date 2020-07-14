class Users::ProductFeatureGroupsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_feature_group, only: [:edit, :update, :destroy]

  def index
    @search_name = params[:feature_name]
    @product_feature_groups = ProductFeatureGroup.search(@search_name).page(params[:page])
  end

  def new
    @product_feature_group = ProductFeatureGroup.new
    last_group = ProductFeatureGroup.last
    @product_feature_group.queue = last_group.present? ? last_group.id + 1 : 1
  end

  def create
    @product_feature_group = ProductFeatureGroup.new(product_feature_group_params)
    if @product_feature_group.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_feature_group.attributes = product_feature_group_params
    if @product_feature_group.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @product_feature_group.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_feature_group
    @product_feature_group = ProductFeatureGroup.find(params[:id])
  end

  def product_feature_group_params
    params.require(:product_feature_group).permit(:queue, :name, :code)
  end
end
