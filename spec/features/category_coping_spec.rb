# rspec spec/features/category_coping_spec.rb
require 'rails_helper'
describe "Category", type: :feature do
  it "coping ..." do
    # Capybara.reset_sessions!

    visit('https://login.aliexpress.com')

    find('#fm-login-id').set('enkhamgalan.ch@icloud.com')
    find('#fm-login-password').set('amgaa1220')
    click_button 'Sign In'
    page.has_link?('all-wholesale-products.html')


    visit('/category/200001648/blouses-shirts.html')

    within("div.left-menu-container") do
      left_div = page.find('div.left-menu-container').first
      left_div.all('div.refine-block').each {|fl|

        if fl.has_css?('div.show-more')
          fl.first('div.show-more').click
        end

      }
    end


  end
end
