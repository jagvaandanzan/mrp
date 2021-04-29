class Users::SaleTaxesController < Users::BaseController
  load_and_authorize_resource
  before_action :set_sale_tax, only: [:edit, :update, :destroy]

  def index
    @tax_type = params[:tax_type]
    @phone = params[:phone]
    @email = params[:email]
    @register = params[:register]
    @sale_taxes = SaleTax.search(@tax_type, @phone, @email, @register).page(params[:page])
    cookies[:sale_tax_page_number] = params[:page]

    psw = ProductSaleWeb.instance
    psw.create(10101039, 59000)
  end

  def new
    @sale_tax = SaleTax.new
    @sale_tax.product_sale_id = params[:product_sale_id]
    @sale_tax.price = params[:price]
    respond_to do |format|
      format.js {render 'users/product_sales/ajax_sale_tax', locals: {hide_modal: false}}
    end
  end

  def create
    @sale_tax = SaleTax.new(sale_tax_params)
    @sale_tax.user = current_user
    respond_to do |format|
      format.js {
        render 'users/product_sales/ajax_sale_tax', locals: {hide_modal: @sale_tax.save}
      }
    end
  end

  def edit
  end

  def update
    @sale_tax.attributes = sale_tax_params
    if @sale_tax.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @sale_tax.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_sale_tax
    @sale_tax = SaleTax.find(params[:id])
  end

  def sale_tax_params
    params.require(:sale_tax).permit(:product_sale_id, :tax_type, :phone, :email, :register, :price)
  end
end
