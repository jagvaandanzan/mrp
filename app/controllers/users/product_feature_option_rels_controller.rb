class Users::ProductFeatureOptionRelsController < Users::BaseController
  before_action :set_product_feature_option_rel, only: [:destroy]

  def index
    @product = Product.find_by!(id: params[:product_id])
    @feature_id = params[:product_feature_id]
    @option_rels = ProductFeatureOptionRel.search(@product.id, @feature_id).page(params[:page])
  end

  def new
    @option_rel = ProductFeatureOptionRel.new
    @product = Product.find_by!(id: params[:product_id])
  end

  def create
    @option_rel = ProductFeatureOptionRel.new(product_feature_option_rel_params)

    if @option_rel.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, product_id: @option_rel.product.id
    else
      render 'new'
    end
  end

  def destroy
    @product_id = @option_rel.product.id
    @option_rel.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, product_id: @product_id
  end

  def get_feature_options
    @feature_options = nil
    if params[:feature_id].present?
      @feature_options =  ProductFeatureOption.search(params[:feature_id], "")
    end

    render json: {options: @feature_options}
  end


  private

  def set_product_feature_option_rel
    @option_rel = ProductFeatureOptionRel.find(params[:id])
  end

  def product_feature_option_rel_params
    params.require(:product_feature_option_rel)
        .permit(:feature_option_id, :product_id, :feature_id)
  end
end
