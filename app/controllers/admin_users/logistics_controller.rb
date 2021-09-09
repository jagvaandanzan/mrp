class AdminUsers::LogisticsController < AdminUsers::BaseController
  load_and_authorize_resource
  before_action :set_logistic, only: [:show, :edit, :update, :destroy]

  def index
    @semail = params[:email]
    @sname = params[:name]
    @sphone = params[:phone]
    @logistics = Logistic.search(@sname, @semail, @sphone).page(params[:page])
    cookies[:logistic_page_number] = params[:page]
  end

  def new
    @logistic = Logistic.new
  end

  def create
    @logistic = Logistic.new(logistic_params)

    if @logistic.save
      @logistic.send_first_password_instructions
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
    @logistic.attributes = logistic_params
    if @logistic.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @logistic.id
    else
      render 'edit'
    end
  end

  def destroy
    @logistic.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  #
  # def logistic_sign_in
  #   sign_in :logistic, @logistic
  #   redirect_to logistics_root_path
  # end

  private

  def set_logistic
    @logistic = Logistic.find(params[:id])
  end

  def logistic_params
    params.require(:logistic).permit(:surname, :name, :gender, :email, :phone,
                                     logistic_permission_rels_attributes: [:id, :logistic_permission_id, :role, :_destroy])
  end
end
