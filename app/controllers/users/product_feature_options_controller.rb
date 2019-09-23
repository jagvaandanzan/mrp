class Users::ProductFeatureOptionsController < Users::BaseController
  before_action :set_product_feature_option, only: [:edit, :update, :destroy]

  def index
    @search_name = params[:option_name]
    @product_feature = ProductFeature.find_by!(id: params[:product_feature_id])
    @options = ProductFeatureOption.search(@product_feature.id, @search_name).page(params[:page])
  end

  def new
    @option = ProductFeatureOption.new
    @option.product_feature = ProductFeature.find_by!(id: params[:product_feature_id])
  end

  def create
    @option = ProductFeatureOption.new(product_feature_option_params)

    if @option.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, product_feature_id: @option.product_feature.id
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @option.attributes = product_feature_option_params
    if @option.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index, product_feature_id: @option.product_feature.id
    else
      render 'edit'
    end
  end

  def destroy
    @product_feature_id = @option.product_feature.id
    @option.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, product_feature_id: @product_feature_id
  end

  private

  def set_product_feature_option
    @option = ProductFeatureOption.find(params[:id])
  end

  def product_feature_option_params
    params.require(:product_feature_option)
        .permit(:product_feature_id, :name)
  end
end
