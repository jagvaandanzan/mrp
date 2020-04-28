# rspec spec/features/bank_transactions_spec.rb
require 'rails_helper'

describe "bank transaction check", type: :feature do
  it "signs me in" do

    Capybara.reset_sessions!
    visit('/')

    within("#Form1") do
      fill_in 'txtCustNo', with: ENV['KHAN_USER']
      fill_in 'txtPassword', with: ENV['KHAN_PASSWORD']
      click_link "btnLogin"
    end

    page.has_selector?('a#cphMain_ctl00_ucAcnt_Menu1_acntJrnl')
    puts "Logged: " + Time.now.to_s
    visit('/pageMain?content=ucAcnt_Statement')
    # fill_in 'ctl00$cphMain$ctl00$numBegDate', with: '2020.01.09'

    find('#cphMain_ctl00_ddlAcntNo').find(:xpath, "option[@value='MNTD0000000#{ENV['ACCOUNT']}']").select_option

    click_link "cphMain_ctl00_btnSearch1"
    page.has_selector?('table#tbl_Stmt')

    puts "tbl_Stmt: " + Time.now.to_s

    while page.has_content?("Цааш нь үзэх")
      puts "click: cphMain_ctl00_btnReadMore => " + Time.now.to_s
      click_link "cphMain_ctl00_btnReadMore"
    end

    transaction_last = nil
    bank_transactions = BankTransaction.by_day(Time.now.beginning_of_day)
    if bank_transactions.present?
      transaction_last = bank_transactions.first
    end
    it_is_new = transaction_last.nil?
    is_created_new = false
    transactions = []
    day = Time.now
    page.all('table#tbl_Stmt tbody tr').each do |tr|
      transaction = BankTransaction.new
      tr.all('td').each_with_index {|td, index|
        data = td.text
        # puts data
        if td[:colspan].present?
          day = Date.strptime(td.find('strong').native.text, "%Y.%m.%d")
        else
          case index
          when 0
            transaction.date = Time.zone.local(day.year, day.month, day.day, data.split(':')[0].to_i, data.split(':')[1].to_i, 0, 0)
          when 1
            transaction.value = data
          when 2
            num = data.gsub(',', '')
            transaction.first_balance = num.to_f.round(1)
          when 3
            num = data.gsub(',', '')
            transaction.summary = num.to_i
          when 4
            num = data.gsub(',', '')
            transaction.final_balance = num.to_f.round(1)
          else #5
            transaction.account = data
          end
        end
      }

      transaction.it_is_new = it_is_new

      if transaction.date.present? && transaction.summary > 0
        # хэрэв өмнө нь гүйлгээ байсан үед, тэрийг олтолоо гүйнэ
        unless it_is_new
          # өмнөх гүйлгээтэй ижил эсэхийг шалгаж байна
          unless transaction_last.nil?
            puts "#{transaction_last.date.strftime('%F %R')} == #{transaction.date.strftime('%F %R')} == #{(transaction_last.date == transaction.date).to_s}"
            puts "#{transaction_last.value} == #{transaction.value} == #{(transaction_last.value == transaction.value).to_s}"
            puts "#{transaction_last.summary} == #{transaction.summary} == #{(transaction_last.summary == transaction.summary).to_s}"
            puts "#{transaction_last.account} == #{transaction.account} == #{(transaction_last.account == transaction.account).to_s}"
          end
          it_is_new = (!transaction_last.nil? &&
              transaction_last.date == transaction.date &&
              transaction_last.value == transaction.value &&
              transaction_last.summary == transaction.summary &&
              transaction_last.account == transaction.account)
        end
        # шинэ гүйлгээ тул хадгална
        if transaction.it_is_new
          transaction.save
          transactions << transaction
          is_created_new = true
        end
      end

    end
    if is_created_new
      check_payment(transactions)
    end
  end
end

def check_payment(transactions)
  # param = API::V1::Entities::BankTransaction.represent transactions
  # ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/newenquiresocial", 'post', param.to_json)
end