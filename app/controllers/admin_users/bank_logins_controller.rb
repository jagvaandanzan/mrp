#intall google-chrome-stable_current_x86_64.rpm
# google-chrome-stable-79.0.3945.130-1.x86_64

require 'capybara/dsl'
require 'selenium/webdriver'

Capybara.default_max_wait_time = 6
Capybara.default_driver = :selenium_chrome
Capybara.javascript_driver = :selenium_chrome
# Capybara.app_host = 'https://m.aliexpress.com'
Capybara.app_host = 'https://www.aliexpress.com'

class AdminUsers::BankLoginsController < AdminUsers::BaseController
  include Capybara::DSL

  def login
    Capybara.reset_sessions!
    visit('https://login.aliexpress.com')
    find('#fm-login-id').set('ariwiseo@gmail.com')
    find('#fm-login-password').set('marketpass1234')
    # click_button 'Sign In'
    # page.has_link?('all-wholesale-products.html')
  end

  def statement
    categories = AliCategory.none_check
    categories.each {|category|
      puts category.name
      visit_link(category, true)
      sleep_visit
    }

  end

  def sleep_visit
    rl = rand(60..90)
    uld = rl % 5
    rl = rl / 5
    (1..rl).each do |i|
      print "#{(i * 5)} "
      STDOUT.flush
      sleep(5)
    end
    sleep(uld)
    puts ""

  end

  def visit_link(category, has_child)
    visit(category.link)
    page.has_content?(category.name)

    within("div.left-menu-container") do
      left_div = page.find("div.left-refine-container", match: :first)

      left_div.all('div.refine-block').each {|fl|
        cls = fl[:class]
        if cls.include?('category')
          if has_child && fl.has_css?('ul.child-menu')
            ul = fl.find(('ul.child-menu'))
            ul.all('li').each {|li|
              a = li.first('a')
              category.sub_categories << AliCategory.new(name: a.text, link: a[:href].gsub('https://www.aliexpress.com', ''))
            }
          end
        elsif cls.include?('custom-text') || cls.include?('custom-img')
          if fl.has_css?('div.show-more')
            fl.first('div.show-more').click
          end

          is_img = cls.include?('custom-img')
          group_name = fl.find('div.title').text

          prod_group = AliFilterGroup.by_name(group_name).order_by
          name_mn = nil
          mn_change = false
          mn_prod = false
          if prod_group.present?
            fg = prod_group.first
            if fg.name_mn.present?
              name_mn = fg.name_mn
            end
            mn_change = fg.mn_change
            mn_prod = fg.prod
          end

          filter_group = AliFilterGroup.new(ali_category: category, name: group_name, name_mn: name_mn, mn_change: mn_change, prod: mn_prod)

          ul = fl.find("ul.inner-item", match: :first)
          ul.all('li').each {|li|
            filter = AliFilter.new(ali_filter_group: filter_group)
            if is_img
              filter.img = li.first('img')[:src]
              filter.mn_change = true
            else
              filter_name = li[:title]
              prod_filter = AliFilter.by_name(filter_name).order_by
              if prod_filter.present?
                ff = prod_filter.first
                if ff.name_mn.present?
                  filter.name_mn = ff.name_mn
                end
                filter.mn_change = ff.mn_change
                filter.prod = ff.prod
              end

              filter.name = filter_name
            end
            filter_group.filters << filter
          }

          category.filter_groups << filter_group
        end
      }
      category.checked = true
      category.save
    end
  end

end