module ApplicationHelper
  def resize_image(path)
    if File.exist?(path)
      geo = Paperclip::Geometry.from_file(path)
      ratio = geo.width / geo.height
      if ratio != 1
        max_dem = geo.width > geo.height ? geo.width : geo.height
        dimensions = "#{max_dem.to_i}x#{max_dem.to_i}"
        puts "convert"
        system("convert -background white -gravity center #{path} -resize #{dimensions} -extent #{dimensions} #{path}")
      else
        puts "ratio == 1"
      end
    else
      puts "file_exit: #{path}"
    end
  end

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
    number_to_currency(value, unit: unit, separator: ".", delimiter: ",", precision: precision, format: "%n%u")
  end

  def local_date(date)
    Time.zone.parse(date.strftime('%F'))
  end

  def get_minutes(date_s, date_f)
    (date_s - date_f) / 1.minutes
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def greetings
    now = Time.now
    today = Date.today.to_time

    morning = today.beginning_of_day
    morning = morning.change(hour: 5)
    noon = today.noon
    evening = today.change(hour: 17)
    night = today.change(hour: 22)

    if (morning..noon).cover? now
      I18n.t('dates.good_morning')
    elsif (noon..evening).cover? now
      I18n.t('dates.good_afternoon')
    elsif (evening..night).cover? now
      I18n.t('dates.good_evening')
    else
      I18n.t('dates.good_night')
    end
  end

  def get_percentage(percent, price)
    if percent == 0
      price
    else
      percent * price / 100
    end
  end

  def only_number(str)
    str.to_s.gsub(/[^0-9]/, '')
  end

  def last_number(obj)
    last = obj.all.last
    last.present? ? last.id + 1 : 1
  end

  def show_id(id)
    if id < 100000
      (100000 + id).to_s
    else
      id.to_s
    end
  end

  def get_code(obj)
    if obj.present?
      code = (100000 + obj.id + 1).to_s
    else
      code = (100001).to_s
    end
    code
  end

  def get_hours(s, e)
    "#{s < 10 ? '0' : ''}#{s}-#{e < 10 ? '0' : ''}#{e}"
  end
end
