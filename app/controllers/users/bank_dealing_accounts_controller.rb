class Users::BankDealingAccountsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_bank_dealing_account, only: [:edit, :update, :destroy]

  def index
    @sname = params[:name]
    @scode = params[:code]
    @saccount = params[:account]
    @bank_dealing_accounts = BankDealingAccount.search(@scode,@snam,@saccount).page(params[:page])
    cookies[:bank_dealing_account_page_number] = params[:page]
  end

  def new
    @bank_dealing_account = BankDealingAccount.new
  end

  def create
    @bank_dealing_account = BankDealingAccount.new(bank_dealing_account_params)

    if @bank_dealing_account.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @bank_dealing_account.attributes = bank_dealing_account_params
    if @bank_dealing_account.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @bank_dealing_account.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_bank_dealing_account
    @bank_dealing_account = BankDealingAccount.find(params[:id])
  end

  def bank_dealing_account_params
    params.require(:bank_dealing_account).permit(:name, :code, :account)
  end
end
