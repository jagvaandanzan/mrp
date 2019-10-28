class Users::ProductsController < Users::BaseController
  # include SearchHelper

  before_action :set_product, only: [:edit, :update, :destroy, :show]

  def index
    @search_name = params[:product_name]
    @products = Product.search(@search_name).page(params[:page])
  end

  def new
    @product = Product.new
    @product.main_code = ApplicationController.helpers.get_code(Product.last)
    feature_rel = ProductFeatureRel.new
    feature_rel.product_feature_option_rels << ProductFeatureOptionRel.new
    @product.product_feature_rels << feature_rel
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :show, id: @product.id
    else
      category_headers
      render 'new'
    end
  end


  def show
  end

  def edit
    category_headers
  end

  def update
    @product.attributes = product_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      category_headers
      render 'edit'
    end
  end

  def destroy
    @product.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def get_product_category_children
    categories = []
    if params[:parent_id].present?
      categories = ProductCategory.search(params[:parent_id])
    end

    render json: {childrens: categories}

  end

  private

  def category_headers
    @headers = ApplicationController.helpers.get_category_parents(@product.category)
    @headers = @headers.reverse
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :detail, :category_id, :code, :main_code, :barcode, :customer_id, :sale_price, :discount_price, :measure, :ptype,
                                    product_feature_rels_attributes: [:id, :image, :barcode, :sale_price, :discount_price, :_destroy,
                                                                      product_feature_option_rels_attributes: [:id, :feature_option_id, :_destroy]])
  end
end
