# rspec spec/features/google_translate_spec.rb
require 'rails_helper'
describe "TranslateGoogle", type: :feature do
  it "translating ..." do
    # ali_categories = AliCategory.all

    ali_filter_group = AliFilterGroup.find(1)
    puts ali_filter_group.name
    #
    # filter_group = CategoryFilterGroup.new(name_en: ali_filter_group.name, name: "test")
    # ali_filter_group.filters.each do |filter|
    #   filter_group.category_filters << CategoryFilter.new(name_en: 'image', name: "test", img: open(filter.img))
    # end

  end
end

