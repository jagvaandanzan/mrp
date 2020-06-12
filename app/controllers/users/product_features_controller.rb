class Users::ProductFeaturesController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_feature, only: [:edit, :update, :destroy]

  def index
    @search_name = params[:feature_name]
    @product_features = ProductFeature.skip_no.search(@search_name).page(params[:page])
  end

  def new
    @product_feature = ProductFeature.new
  end

  def create
    @product_feature = ProductFeature.new(product_feature_params)
    if @product_feature.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_feature.attributes = product_feature_params
    if @product_feature.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @product_feature.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_feature
    @product_feature = ProductFeature.find(params[:id])
  end

  def product_feature_params
    params.require(:product_feature).permit(:feature_type, :queue, :name, :description)
  end
end
