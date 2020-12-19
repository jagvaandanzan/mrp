class Users::BankAccountsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_bank_account, only: [:edit, :update, :destroy]

  def index
    @sname = params[:name]
    @scode = params[:code]
    @sname_en = params[:name_en]
    @saccount = params[:account]
    @bank_accounts = BankAccount.search(@scode,@sname,@sname_en,@saccount).page(params[:page])
    cookies[:bank_account_page_number] = params[:page]
  end

  def new
    @bank_account = BankAccount.new
  end

  def create
    @bank_account = BankAccount.new(bank_account_params)

    if @bank_account.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @bank_account.attributes = bank_account_params
    if @bank_account.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @bank_account.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_bank_account
    @bank_account = BankAccount.find(params[:id])
  end

  def bank_account_params
    params.require(:bank_account).permit(:name, :code, :name_en, :account)
  end
end
