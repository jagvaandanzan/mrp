class Users::SalesmenController < Users::BaseController
  load_and_authorize_resource
  before_action :set_salesman, only: [:show, :edit, :update, :destroy]

  def index
    @sid = params[:id]
    @sname = params[:name]
    @sphone = params[:phone]
    @salesmen = Salesman.search(@sid, @sname, @sphone).page(params[:page])
    cookies[:salesman_page_number] = params[:page]
  end

  def new
    @salesman = Salesman.new
    @salesman.price = Const::DISTRIBUTION[2]
  end

  def create
    @salesman = Salesman.new(salesman_params)

    if @salesman.save
      # @salesman.send_first_password_instructions
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      logger.debug(@salesman.errors.full_messages)
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @salesman.attributes = salesman_params
    if @salesman.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @salesman.id
    else
      render 'edit'
    end
  end

  def destroy
    @salesman.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_salesman
    @salesman = Salesman.find(params[:id])
  end

  def salesman_params
    params.require(:salesman).permit(:avatar, :surname, :name, :gender, :register, :email, :phone, :address, :price, :distribution, :price_at)
  end
end
