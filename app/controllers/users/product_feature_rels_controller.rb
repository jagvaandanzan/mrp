class Users::ProductFeatureRelsController < Users::BaseController
  before_action :set_product_feature_rel, only: [:edit, :update, :destroy]

  def index
    @product = Product.find_by!(id: params[:product_id])
    @product_feature_rels = ProductFeatureRel.search(@product.id).page(params[:page])
  end

  def new
    @product_feature_rel = ProductFeatureRel.new
    @product = Product.find_by!(id: params[:product_id])
    @product_feature_rel.product = @product
    @product_feature_rel.sale_price = @product.sale_price
    @product_feature_rel.discount_price = @product.discount_price
    @product_feature_rel.barcode = @product.barcode
  end

  def create
    @product_feature_rel = ProductFeatureRel.new(product_feature_rel_params)

    if @product_feature_rel.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, product_id: @product_feature_rel.product.id
    else
      Rails.logger.debug("error_message: "+@product_feature_rel.errors.full_messages.to_s)
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_feature_rel.attributes = product_feature_rel_params
    if @product_feature_rel.save

      flash[:success] = t('alert.info_updated')
      # redirect_to action: :show, id: @product.id
      redirect_to action: 'index', product_id: @product_feature_rel.product.id
    else
      render 'edit'
    end
  end


  def destroy
    @product_id = @product_feature_rel.product.id
    @product_feature_rel.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, product_id: @product_id
  end


  private

  def set_product_feature_rel
    @product_feature_rel = ProductFeatureRel.find(params[:id])
  end

  def product_feature_rel_params
    params.require(:product_feature_rel)
        .permit(:product_id, :sale_price, :discount_price, :barcode,
                product_feature_option_rels_attributes: [:id, :feature_option_id, :_destroy])
  end
end
