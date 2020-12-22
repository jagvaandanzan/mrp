class Users::BankTransactionsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_bank_transaction, only: [:edit, :update, :show, :destroy]

  def index
    @value = params[:value]
    @account = params[:account]
    @min = params[:min]
    @max = params[:max]
    @date = if params[:date].present?
              params[:date].to_time
            else
              Time.now.beginning_of_day
            end

    @salesman = params[:salesman]
    @bank_account = params[:bank_account]
    @dealing_account = params[:dealing_account]
    @billing_date = if params[:billing_date].present?
                      params[:billing_date].to_time
                    end
    @bank_transactions = BankTransaction.search(nil, @value, @account, @min, @max, @date, @salesman, @bank_account, @dealing_account, @billing_date)
                             .page(params[:page])
    cookies[:bank_transaction_page_number] = params[:page]

  end

  def new
    @bank_transaction = BankTransaction.new
  end

  def create
    @bank_transaction = BankTransaction.new(bank_transaction_params)
    @bank_transaction.is_manual = true

    if @bank_transaction.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
  end

  def edit
    unless @bank_transaction.manual
      redirect_to action: :index
    end
  end

  def update
    @bank_transaction.attributes = bank_transaction_params
    @bank_transaction.is_manual = true
    if @bank_transaction.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @bank_transaction.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_bank_transaction
    @bank_transaction = BankTransaction.find(params[:id])
  end

  def bank_transaction_params
    params.require(:bank_transaction).permit(:date, :salesman_id, :bank_account_id, :dealing_account_id, :billing_date, :value, :summary)
  end

end
