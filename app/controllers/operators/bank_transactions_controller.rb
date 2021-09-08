class Operators::BankTransactionsController < Operators::BaseController
  load_and_authorize_resource

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
    phones = if current_operator.present?
               Salesman.order_name.map(&:phone).to_a
             end

    @bank_transactions = BankTransaction.is_income
                             .by_manual
                             .search(phones, @value, @account, @min, @max, @date).page(params[:page])
    cookies[:bank_transaction_page_number] = params[:page]

  end
end
