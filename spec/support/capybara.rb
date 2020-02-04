# intall google-chrome-stable_current_x86_64.rpm
# google-chrome-stable-79.0.3945.130-1.x86_64

require 'capybara/rspec'
require 'capybara/dsl'
require 'selenium/webdriver'

Capybara.default_max_wait_time = 6
Capybara.default_driver = :selenium_chrome
Capybara.javascript_driver = :selenium_chrome
# Capybara.app_host = 'https://m.aliexpress.com'
Capybara.app_host = 'https://www.aliexpress.com'