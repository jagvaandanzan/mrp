class Users::ProductSuppliersController < Users::BaseController
  before_action :set_product_supplier, only: [:edit, :update, :destroy, :show]

  def index
    @search_name = params[:supplier_name]
    @product_suppliers = ProductSupplier.search(@search_name).page(params[:page])
  end

  def new
    lastSupp = ProductSupplier.last
    @product_supplier = ProductSupplier.new

    @product_supplier.code = (100000+lastSupp.id+1).to_s
  end

  def create
    @product_supplier = ProductSupplier.new(product_supplier_params)
    if @product_supplier.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :show, id: @product_supplier.id
    else
      render 'new'
    end
  end


  def show
  end

  def edit
  end

  def update
    @product_supplier.attributes = product_supplier_params
    if @product_supplier.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :show, id: @product_supplier.id
    else
      render 'edit'
    end
  end

  def destroy
    @product_supplier.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_supplier
    @product_supplier = ProductSupplier.find(params[:id])
  end

  def product_supplier_params
    params.require(:product_supplier).permit(:code, :name, :description)
  end
end
