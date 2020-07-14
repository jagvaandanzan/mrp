class Users::ProductFeatureOptionsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_feature_option, only: [:edit, :update, :destroy]

  def index
    @search_name = params[:option_name]
    @group_id = params[:group_id]
    @product_feature = ProductFeature.find_by!(id: params[:product_feature_id])
    @options = ProductFeatureOption.search(@product_feature.id, @search_name, @group_id).page(params[:page])
  end

  def new
    @option = ProductFeatureOption.new
    @option.product_feature = ProductFeature.find_by!(id: params[:product_feature_id])
    if params[:group_id].present?
      @option.queue = ProductFeatureOption.by_group_id(params[:group_id]).count + 1
      @option.group_id = params[:group_id]
      @option.code = @option.group.code
    end
  end

  def create
    @option = ProductFeatureOption.new(product_feature_option_params)

    if @option.save
      flash[:success] = t('alert.saved_successfully')
      if @option.group.present?
        redirect_to action: :index, product_feature_id: @option.product_feature.id, group_id: @option.group_id
      else
        redirect_to action: :index, product_feature_id: @option.product_feature.id
      end
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
      if @option.group.present?
        redirect_to action: :index, product_feature_id: @option.product_feature.id, group_id: @option.group_id
      else
        redirect_to action: :index, product_feature_id: @option.product_feature.id
      end
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
    params.require(:product_feature_option).permit(:product_feature_id, :group_id, :queue, :name, :code)
  end
end
