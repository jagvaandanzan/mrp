module ApplicationHelper
  def get_f(number)
    if number.nil?
      0
    else
      # sprintf("%g", number)
      if number % 1 == 0
        number.to_i
      else
        number
      end
    end
  end

  def get_currency_mn(value)
    get_currency(value, "₮", 0)
  end

  def get_currency(value, unit, precision)
    number_to_currency(value, unit: unit, separator: ".", delimiter: ",", precision: precision, format: "%n %u")
  end

  def local_date(date)
    Time.zone.parse(date.strftime('%F'))
  end
end
