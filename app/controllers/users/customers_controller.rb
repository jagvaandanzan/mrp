class Users::CustomersController < Users::BaseController
  load_and_authorize_resource
  before_action :set_customer, only: [:edit, :update, :destroy, :show]

  def index
    @customer_name = params[:customer_name]
    @customers = Customer.search(@customer_name).page(params[:page])
  end

  def new
    @customer = Customer.new
    @customer.queue = Customer.all.count + 1
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :show, id: @customer.id
    else
      render 'new'
    end
  end


  def show
  end

  def edit
  end

  def update
    @customer.attributes = customer_params
    if @customer.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :show, id: @customer.id
    else
      render 'edit'
    end
  end

  def destroy
    @customer.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:logo, :c_type, :queue, :code, :name, :description,
                                     customer_contact_fees_attributes: [:id, :range_s, :range_e, :percent, :_destroy],
                                     customer_contacts_attributes: [:id, :delivery, :condition, :price, :_destroy])
  end
end
