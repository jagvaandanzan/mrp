class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(phone, message, mn)
    ApplicationController.helpers.send_sms(phone, mn.nil? ? message : message.gsub(":mn", cyrillic_to_latin(mn)))
  end

  def cyrillic_to_latin(text)
    latin = ""
    text.downcase.split('').each_with_index do |c, index|
      latin += index == 0 ? cyrill_to_latin(c).upcase : cyrill_to_latin(c)
    end
    latin
  end

  def cyrill_to_latin(c)
    case c
    when 'а'
      'a'
    when 'б'
      'b'
    when 'в'
      'w'
    when 'г'
      'g'
    when 'д'
      'd'
    when 'е'
      'e'
    when 'ё'
      'yo'
    when 'ж'
      'j'
    when 'з'
      'z'
    when 'и'
      'i'
    when 'й'
      'i'
    when 'к'
      'k'
    when 'л'
      'l'
    when 'м'
      'm'
    when 'н'
      'n'
    when 'о'
      'o'
    when 'ө'
      'u'
    when 'п'
      'p'
    when 'р'
      'r'
    when 'с'
      's'
    when 'т'
      't'
    when 'у'
      'u'
    when 'ү'
      'v'
    when 'ф'
      'f'
    when 'х'
      'h'
    when 'ц'
      'c'
    when 'ч'
      'ch'
    when 'ш'
      'sh'
    when 'ъ'
      'i'
    when 'ь'
      'i'
    when 'э'
      'e'
    when 'ы'
      'ii'
    when 'ю'
      'yu'
    when 'я'
      'ya'
    else
      c
    end
  end
end
