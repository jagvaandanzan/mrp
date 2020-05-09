class BankTransactionJob < ApplicationJob
  queue_as :default

  def perform(bank_transaction)
    ActionCable.server.broadcast 'bank_transaction_channel', bank_transaction: render(bank_transaction)
  end

  private

  def render(bank_transaction)
    ApplicationController.renderer.render(partial: 'operators/bank_transactions/row_index', locals: {bank_transaction: bank_transaction})
  end
end
