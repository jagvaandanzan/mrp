class AdminUsers::AdministratorsController < AdminUsers::BaseController
  before_action :set_admin_user, only: [:edit, :update, :destroy]

  def index
    @admin_users = AdminUser.all.page(params[:page])
  end

  def new
    @admin_user = AdminUser.new
  end

  def create
    @admin_user = AdminUser.new(admin_user_params)

    if @admin_user.save
      @admin_user.send_first_password_instructions
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update

    @admin_user.attributes = admin_user_params
    if @admin_user.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @admin_user.destroy!

    flash[:success] = t('alert.deleted_successfully')
    render json: {status: 'ok'}
  end

  private

  def set_admin_user
    @admin_user = AdminUser.find(params[:id])
  end

  def admin_user_params
    params.require(:admin_user).permit(:email, :admin_permission_id)
  end
end