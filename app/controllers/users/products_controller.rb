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
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = t('alert.saved_successfully')
      # redirect_to action: :show, id: @product.id
      redirect_to action: 'index'
    else
      render 'new'
    end
  end


  def show
  end

  def edit
    @headers = ApplicationController.helpers.get_category_parents(@product.category)
    @headers = @headers.reverse()
  end

  def update
    @product.attributes = product_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      # redirect_to action: :show, id: @product.id
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @product.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def get_product_category_children
    @categories = nil
    if params[:parent_id].present?
      @categories =  ProductCategory.search(params[:parent_id])
    end

    render json: {childrens: @categories}
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    # params.require(:product_supplier).permit(:code, :name, :description)
    params.require(:product).permit(:name, :code, :main_code, :barcode, :detail, :measure, :ptype, :category_id)
  end
end
