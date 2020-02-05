# rspec spec/features/category_coping_spec.rb
require 'rails_helper'
describe "Category", type: :feature do
  it "coping ..." do

    Capybara.reset_sessions!
    visit('https://login.aliexpress.com')
    find('#fm-login-id').set('ariwiseo@gmail.com')
    find('#fm-login-password').set('marketpass1234')
    click_button 'Sign In'
    page.has_link?('all-wholesale-products.html')

    categories = AliCategory.parent_nil
    categories.each do |category|

      unless category.checked
        puts category.name
        visit_link(category, false)
        sleep_visit
      end

      category.sub_categories.none_check.each {|sub|
        puts sub.name
        visit_link(sub, true)
        sleep_visit
      }
    end

  end
end

def sleep_visit
  rl = rand(61..120)
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
        if fl.has_content?('View More')
          fl.find(:class, '.show-more').click
          # fl.first('div.show-more').wait_while(&:obscured?).click
        end

        is_img = cls.include?('custom-img')

        filter_group = AliFilterGroup.new(ali_category: category, name: fl.find('div.title').text)

        ul = fl.find("ul.inner-item", match: :first)
        ul.all('li').each {|li|
          filter = AliFilter.new(ali_filter_group: filter_group)
          if is_img
            filter.img = li.first('img')[:src]
          else
            filter.name = li[:title]
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
