class UserMailer < BaseMailer

  def headers_for(action, opts)
    super.merge!({template_path: 'mailer/user'})
  end

  def first_password_instructions(record, password, opts = {})
    @password = password
    devise_mail(record, :first_password_instructions, opts)
  end

  def reset_password_app(record, email, url_token, opts = {})
    @email = email
    @url_token = url_token
    devise_mail(record, :reset_password_app, opts)
  end

  def send_tax(record, price, code, number, qr, opts = {})
    @price = price
    @code = code
    @number = number
    @qr = qr
    devise_mail(record, :send_tax, opts)
  end

end
