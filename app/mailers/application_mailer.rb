class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILER_SENDER'], to: ENV['MAILER_RECEIVER']
  layout 'mailer'
end
