class SalesmanMailer < BaseMailer

  def headers_for(action, opts)
    super.merge!({template_path: 'mailer/salesman'})
  end

  def first_password_instructions(record, password, opts = {})
    @password = password
    devise_mail(record, :first_password_instructions, opts)
  end

end
