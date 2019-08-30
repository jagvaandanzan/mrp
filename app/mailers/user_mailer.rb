class UserMailer < Devise::Mailer
  layout 'mailer'

  def first_password_instructions(record, password, opts = {})
    @password = password
    devise_mail(record, :first_password_instructions, opts)
  end

end
