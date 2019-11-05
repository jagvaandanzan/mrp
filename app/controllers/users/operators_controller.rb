class Users::OperatorsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_operator, only: [:show, :edit, :update, :destroy]

  def index
    @semail = params[:email]
    @sname = params[:name]
    @sphone = params[:phone]
    @operators = Operator.search(@sname, @semail, @sphone).page(params[:page])
    cookies[:operator_page_number] = params[:page]
  end

  def new
    @operator = Operator.new
  end

  def create
    @operator = Operator.new(operator_params)

    if @operator.save
      @operator.send_first_password_instructions
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @operator.attributes = operator_params
    if @operator.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @operator.id
    else
      render 'edit'
    end
  end

  def destroy
    @operator.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end
  #
  # def operator_sign_in
  #   sign_in :operator, @operator
  #   redirect_to operators_root_path
  # end

  private

  def set_operator
    @operator = Operator.find(params[:id])
  end

  def operator_params
    params.require(:operator).permit(:surname, :name, :gender, :email, :phone)
  end
end
