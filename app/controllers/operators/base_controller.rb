class Operators::BaseController < ApplicationController
  layout 'operator'

  before_action do
    set_locale
    authenticate_operator!
    redirect_to operator_passwords_edit_password_path if current_operator.password_is_reset
  end

  def root
    path = if can? :read, FbComment
             operators_fb_comments_path
           elsif can? :read, BankTransaction
             operators_bank_transactions_path
           elsif can? :read, SmsMessage
             operators_sms_messages_path
           else
             operators_product_sales_path
           end

    redirect_to path
  end

  def routing_error
    redirect_to operators_root_path
  end

  def set_locale
    I18n.locale = params[:locale] || :mn
  end

end
