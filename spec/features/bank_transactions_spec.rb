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
    transaction_in = []
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

        # ?????????? ?????????????? ?????????????? ??????????????
        # is_old = (!transaction_last.nil? &&
        #     (transaction_last.date == transaction.date || time_now.hour < 10) &&
        #     transaction_last.value == transaction.value &&
        #     transaction_last.summary == transaction.summary &&
        #     transaction_last.account == transaction.account)

        # ???????? ?????????????? ?????? ????????????????
        unless hash_bank_transactions["#{transaction.value}_#{transaction.summary}_#{transaction.account}"].present?
          #   break
          transaction.save
          transactions << transaction
          if transaction.summary > 0
            transaction_in << transaction
            is_created_new = true
          end
        end
      end

    end
    if transactions.length > 0
      check_payment(transactions, is_created_new, transaction_in)
    end
  end
end

def check_payment(transactions, is_created_new, transaction_in)
  param = API::V1::Entities::BankTransaction.represent transactions
  response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/savebanktrans", 'post', param.to_json)
  # Rails.logger.debug("43.231.114.241:8882/api/savebanktrans => #{param.to_json}")
  # Rails.logger.debug("43.231.114.241:8882/api/savebanktrans => #{response.code.to_s} => #{response.body.to_s}")
  if is_created_new
    ids = []
    transaction_in.each do |transaction|
      Rails.logger.debug "transaction.value => #{transaction.value}"
      if transaction.value.downcase.match(/[wk][0-9]{8}/)
        if transaction.value.downcase.include?('qpay')
          transaction_id = transaction.value.downcase.match(/[k]\d+[0-9]/).to_s
          payment = transaction.summary / 99 * 100
        else
          transaction_id = transaction.value.downcase.match(/[w]\d+[0-9]/).to_s
          payment = transaction.summary
        end

        puts "bank_send_mrp-enquire => #{transaction_id[1..transaction_id.length]} => #{payment}"
        Rails.logger.debug "bank_send_mrp-enquire => #{transaction_id[1..transaction_id.length]} => #{payment}"
        psw = ProductSaleWeb.instance
        psw.create(transaction_id[1..transaction_id.length], payment)
      end
      ids << transaction.id
    end

    ApplicationController.helpers.api_send("#{ENV['DOMAIN_NAME']}/api/v1/notifications/bank", 'post', {ids: ids}.to_json)
  end
end