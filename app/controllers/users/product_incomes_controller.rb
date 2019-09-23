class Users::ProductIncomesController < Users::BaseController
  before_action :set_product_income, only: [:edit, :update, :destroy]

  def index
    @by_code = params[:by_code]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @incomes = ProductIncome.search(@by_code, @by_start, @by_end).page(params[:page])
  end

  def new
    @product_income = ProductIncome.new
    @product_income.income_date = Time.current
    @product_income.code = ApplicationController.helpers.get_code(ProductIncome.last)
  end

  def create
    @product_income = ProductIncome.new(product_income_params)
    if @product_income.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_income.attributes = product_income_params
    if @product_income.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @product_income.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_income
    @product_income = ProductIncome.find(params[:id])
  end

  def product_income_params
    params.require(:product_income).permit(:code, :income_date, :supplier_id, :note)
  end
end
