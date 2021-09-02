class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(phone, message)
    ApplicationController.helpers.send_sms(phone, message)
  end
end
