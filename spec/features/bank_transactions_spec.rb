# rspec spec/features/bank_transactions_spec.rb
require 'rails_helper'

describe "bank transaction check", type: :feature do
  it "signs me in" do

    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(1600, 1200)
    visit('/')

    within(".ant-form-horizontal") do
      fill_in 'username', with: ENV['KHAN_USER']
      fill_in 'password', with: ENV['KHAN_PASSWORD']
      sleep 2.second
      find('button', class: 'login-button').click
    end
    puts "click 1: " + Time.now.to_s

    sleep 30.second
    page.has_selector?('li.icon-savingsFilled')
    puts "Logged: " + Time.now.to_s

    find('i', class: 'icon-savingsFilled').click
    # puts page.body

    # page.execute_script("$(#{selector}).click()")
    find(:xpath, "//a[@href='/account/statement/#{ENV['ACCOUNT']}/MNT/OPR']").click
    # fill_in 'ctl00$cphMain$ctl00$numBegDate', with: '2020.01.09'

    sleep 30.second
    page.has_selector?('div#rc-tabs-0-panel-1')
    page.has_selector?('table.statement-table')
    puts "tbl_Stmt: " + Time.now.to_s

    # transaction_last = nil
    bank_transactions = BankTransaction.by_day(Time.now.beginning_of_day)
    hash_bank_transactions = bank_transactions.map {|i| ["#{i.value}_#{i.summary}_#{i.account}", i]}.to_h
    # if bank_transactions.present?
    #   transaction_last = bank_transactions.first
    # end
    is_created_new = false
    transactions = []
    day = Time.now
    page.all('div#rc-tabs-0-panel-1 tr').each do |tr|
      transaction = BankTransaction.new
      tr.all('td').each_with_index {|td, index|
        data = td.text
        # puts data
        if td[:colspan].present?
          day = Date.strptime(data, "%Y-%m-%d")
        else
          case index
          when 0
            transaction.date = Time.zone.local(day.year, day.month, day.day, data.split(':')[0].to_i, data.split(':')[1].to_i, 0, 0)
          when 1
            transaction.value = data
          when 2
            num = data.gsub(',', '').gsub(' ', '')
            transaction.first_balance = num.to_f.round(1)
          when 3
            num = data.gsub(',', '').gsub(' ', '')
            transaction.summary = num.to_f.round(1)
          when 4
            num = data.gsub(',', '').gsub(' ', '')
            transaction.final_balance = num.to_f.round(1)
          else #5
            transaction.account = data.gsub(' ', '')
          end
        end
      }

      if transaction.date.present?
        # time_now = Time.current
        # unless transaction_last.nil?
        #   Rails.logger.debug("#{transaction_last.date.strftime('%F %R')} == #{transaction.date.strftime('%F %R')} == #{(transaction_last.date == transaction.date).to_s} ==> #{time_now.hour}")
        #   Rails.logger.debug("#{transaction_last.value} == #{transaction.value} == #{(transaction_last.value == transaction.value).to_s}")
        #   Rails.logger.debug("#{transaction_last.summary} == #{transaction.summary} == #{(transaction_last.summary == transaction.summary).to_s}")
        #   Rails.logger.debug("#{transaction_last.account} == #{transaction.account} == #{(transaction_last.account == transaction.account).to_s}")
        # end

        # Өмнөх гүйлгээ эсэхийг шалгана
        # is_old = (!transaction_last.nil? &&
        #     (transaction_last.date == transaction.date || time_now.hour < 10) &&
        #     transaction_last.value == transaction.value &&
        #     transaction_last.summary == transaction.summary &&
        #     transaction_last.account == transaction.account)

        # шинэ гүйлгээ тул хадгална
        if hash_bank_transactions["#{transaction.value}_#{transaction.summary}_#{transaction.account}"].present?
          break
        else
          transaction.save
          # орлого бол шалгана
          if transaction.summary > 0
            transactions << transaction
            is_created_new = true
          end
        end
      end

    end
    if is_created_new
      check_payment(transactions)
    end
  end
end

def check_payment(transactions)
  param = API::V1::Entities::BankTransaction.represent transactions
  response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/savebanktrans", 'post', param.to_json)
  # Rails.logger.debug("43.231.114.241:8882/api/savebanktrans => #{param.to_json}")
  # Rails.logger.debug("43.231.114.241:8882/api/savebanktrans => #{response.code.to_s} => #{response.body.to_s}")

  ids = []
  transactions.each do |transaction|
    if transaction.value.downcase.match(/[wq][0-9]{8}/)
      if transaction.value.downcase.start_with?('qpay', 'mm:qpay')
        transaction_id = transaction.value.downcase.match(/[q]\d+[0-9]/).to_s
        payment = transaction.summary / 99 * 100
        param_old = {
            amount: payment,
            type: "QPAY",
            transactionNumber: transaction_id[1..transaction_id.length],
            ibank_id: 0
        }
      else
        transaction_id = transaction.value.downcase.match(/[w]\d+[0-9]/).to_s
        payment = transaction.summary
        param_old = {
            amount: payment,
            type: "WEB",
            transactionNumber: transaction_id[1..transaction_id.length],
            ibank_id: 0
        }
      end
      ApplicationController.helpers.sent_market_web("https://market.mn/api/payments", 'post', param_old.to_json)

      param = {
          code: transaction_id[1..transaction_id.length],
          pay: payment
      }
      response = ApplicationController.helpers.api_request('sales/payment', 'post', param.to_json)
      if response.code.to_i == 201
        json = JSON.parse(response.body)
        cart = json['cart']
        l = cart['location']
        d = cart['delivery_date'].split("-").map(&:to_i)
        start_time = cart['start_time'].split(":").map(&:to_i)
        end_time = cart['end_time'].split(":").map(&:to_i)

        product_sale = ProductSale.new(phone: cart['phone'],
                                       hour_start: start_time[0],
                                       hour_end: end_time[0],
                                       loc_note: cart['description'],
                                       delivery_start: DateTime.new(d[0], d[1], d[2], start_time[0], 0, 0, 8),
                                       delivery_end: DateTime.new(d[0], d[1], d[2], end_time[0], 0, 0, 8),
                                       sum_price: cart['payment'],
                                       bonus: cart['bonus'],
                                       money: 1,
                                       paid: cart['payment'],
                                       cart_id: cart['id'])

        if l['mrp_location_id'].present?
          product_sale.location = Location.find(l['mrp_location_id'])
          product_sale.status = ProductSaleStatus.find_by_alias("oper_confirmed")
        else
          loc_khoroo = LocKhoroo.find(l['loc_khoroo_id'])
          nl = Location.new(loc_district_id: loc_khoroo.loc_district_id,
                            loc_khoroo_id: l['loc_khoroo_id'],
                            micro_region: l['micro_region'],
                            town: l['town'],
                            street: l['street'],
                            apartment: l['apartment'],
                            entrance: l['entrance'],
                            latitude: l['latitude'],
                            longitude: l['longitude'],
                            approved: false,
                            web_location_id: l['id'])
          nl.save(validate: false)
          product_sale.location = nl
          product_sale.status = ProductSaleStatus.find_by_alias("oper_from_web")
        end

        cart['cart_items'].each do |item|
          sale_item = ProductSaleItem.new(product_id: item['product_id'])
          feature_item = ProductFeatureItem.find(item['product_feature_item_id'])
          sale_item.feature_item = feature_item
          sale_item.remainder = feature_item.balance
          sale_item.quantity = item['quantity']
          sale_item.p_price = feature_item.price.presence || 0
          sale_item.p_6_8 = feature_item.p_6_8.presence || 0
          sale_item.p_9_ = feature_item.p_9_.presence || 0
          sale_item.price = feature_item.price_quantity(sale_item.quantity).presence || 0
          # Хэрэв хямдралтай бол
          product_discounts = sale_item.product.product_discounts.by_available
          if product_discounts.present?
            discount = product_discounts.first
            sale_item.discount = discount.percent
            sale_item.price -= ApplicationController.helpers.get_percentage(sale_item.price, discount.percent)
          end
          sum_price = sale_item.price * sale_item.quantity
          sale_item.sum_price = sum_price

          product_sale.product_sale_items << sale_item
        end

        if product_sale.save
          ApplicationController.helpers.send_sms(product_sale.phone, "Tani zahialga batalgaajlaa. Market.mn")
        else
          Rails.logger.info("SAVE_zahialga: #{product_sale.errors.full_messages}")
          ApplicationController.helpers.send_sms(product_sale.phone, "Tani zahialga amjiltgui bolloo. Ta 7777-9990 dugaart handana uu?")
        end
      end
    end
    ids << transaction.id
  end

  ApplicationController.helpers.api_send("#{ENV['DOMAIN_NAME']}/api/v1/notifications/bank", 'post', {ids: ids}.to_json)


end