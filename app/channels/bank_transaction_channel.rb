class BankTransactionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bank_transaction_channel"
  end

  def unsubscribed
  end
end
