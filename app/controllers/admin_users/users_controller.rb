class AdminUsers::UsersController < AdminUsers::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @semail = params[:email]
    @sname = params[:name]
    @sphone = params[:phone]
    @users = User.search(@sname, @semail, @sphone).page(params[:page])
    cookies[:user_page_number] = params[:page]
    ProductFeatureOption.by_group_id(1).limit(3).each do |opt|
      category = CategoryFilter.find_by_name_en(opt.name_en)
      if category.present?
        opt.update_attribute(:name, category.name)
      end
    end
  end

  def new
    @user = User.new
    @user.user_permission_rels << UserPermissionRel.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_first_password_instructions
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
    @user.attributes = user_params
    if @user.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @user.id
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  # def user_sign_in
  #   sign_in :user, @user
  #   redirect_to users_root_path
  # end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:surname, :name, :gender, :email, :phone, :user_position_id,
                                 user_permission_rels_attributes: [:id, :user_permission_id, :role, :_destroy])
  end
end
