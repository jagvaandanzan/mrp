class OperatorMailer < BaseMailer

  def headers_for(action, opts)
    super.merge!({template_path: 'mailer/operator'})
  end

  def first_password_instructions(record, password, opts = {})
    @password = password
    devise_mail(record, :first_password_instructions, opts)
  end

end
