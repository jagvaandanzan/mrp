#intall google-chrome-stable_current_x86_64.rpm
# google-chrome-stable-79.0.3945.130-1.x86_64
# for select == find('#cphMain_ctl00_ddlAcntNo').find(:xpath, "option[@value='MNTD0000000#{ENV['ACCOUNT']}']").select_option
# click_link "cphMain_ctl00_btnSearch1"
# # while page.has_selector?("a#cphMain_ctl00_btnReadMore")
# while page.has_content?("Цааш нь үзэх")
#   puts "click: cphMain_ctl00_btnReadMore => " + Time.now.to_s
#   click_link "cphMain_ctl00_btnReadMore"
# end

require 'capybara/dsl'
require 'selenium/webdriver'

Capybara.default_max_wait_time = 6
Capybara.default_driver = :selenium_chrome
Capybara.javascript_driver = :selenium_chrome
Capybara.app_host = 'https://e.khanbank.com'
class AdminUsers::BankLoginsController < AdminUsers::BaseController
  include Capybara::DSL
  # http://157.245.203.167/api/incomes
  # User ganzorige
  # Pass Ganzorig1025@
  # Tgd 5111373200 dansiig harna
  def login

    Capybara.reset_sessions!
    visit('/')

    within(".ant-form-horizontal") do
      fill_in 'username', with: ENV['KHAN_USER']
      fill_in 'password', with: ENV['KHAN_PASSWORD']
      find('span', text: 'НЭВТРЭХ').click
    end

    # sleep 3.minute
    page.has_selector?('li.icon-savingsFilled')
    puts "Logged: " + Time.now.to_s
    # visit("/account/statement/5070341577/MNT/OPR")
    find('i', class: 'icon-savingsFilled').click
    find(:xpath, "//a[@href='/account/statement/5070341577/MNT/OPR']").click

    sleep 1.minute

    page.has_selector?('div#rc-tabs-0-panel-1')
    page.has_selector?('table.statement-table')
    puts "tbl_Stmt: " + Time.now.to_s

    transaction_last = nil
    bank_transactions = BankTransaction.by_day(Time.now.beginning_of_day)
    if bank_transactions.present?
      transaction_last = bank_transactions.first
    end
    it_is_new = transaction_last.nil?
    is_created_new = false
    transactions = []
    day = Time.now
    # puts page.body
    page.all('div#rc-tabs-0-panel-1 tr').each do |tr|
      transaction = BankTransaction.new
      tr.all('td').each_with_index {|td, index|
        data = td.text
        puts data
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

      transaction.it_is_new = it_is_new

      if transaction.date.present?
        # хэрэв өмнө нь гүйлгээ байсан үед, тэрийг олтолоо гүйнэ
        unless it_is_new
          # өмнөх гүйлгээтэй ижил эсэхийг шалгаж байна
          time_now = Time.current
          it_is_new = (!transaction_last.nil? &&
              (transaction_last.date == transaction.date || time_now.hour < 10) &&
              transaction_last.value == transaction.value &&
              transaction_last.summary == transaction.summary &&
              transaction_last.account == transaction.account)

          # unless transaction_last.nil?
          #   Rails.logger.debug("#{transaction_last.date.strftime('%F %R')} == #{transaction.date.strftime('%F %R')} == #{(transaction_last.date == transaction.date).to_s} ==> #{time_now.hour}")
          #   Rails.logger.debug("#{transaction_last.value} == #{transaction.value} == #{(transaction_last.value == transaction.value).to_s}")
          #   Rails.logger.debug("#{transaction_last.summary} == #{transaction.summary} == #{(transaction_last.summary == transaction.summary).to_s}")
          #   Rails.logger.debug("#{transaction_last.account} == #{transaction.account} == #{(transaction_last.account == transaction.account).to_s}")
          # end
          # Rails.logger.debug("it_is_new_2=#{it_is_new}")
        end
        # Rails.logger.debug("it_is_new_3=#{it_is_new}")
        # шинэ гүйлгээ тул хадгална
        if transaction.it_is_new
          transaction.save
          # орлого бол шалгана
          transactions << transaction if transaction.summary > 0
          is_created_new = true
        end
      end

    end
    if is_created_new
      check_payment(transactions)
    end
  end

  def check_payment(transactions)
    transactions.each do |transaction|
      Rails.logger.info(transaction.value)
    end
  end
end