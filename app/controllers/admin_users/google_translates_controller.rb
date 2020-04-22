class AdminUsers::GoogleTranslatesController < AdminUsers::BaseController
  require "google/cloud/translate"

  def translate_prod
    ali_filters = AliFilterGroup.name_mn_nil

    ali_filters.each do |gr|
      list = AliFilterGroup.by_name(gr.name).name_mn_not_nil
      if list.present?
        ff = list.first
        gr.update(name_mn: ff.name_mn)
      end
    end

    ali_filters = AliFilter.name_mn_nil

    ali_filters.each do |gr|
      list = AliFilter.by_name(gr.name).name_mn_not_nil
      if list.present?
        ff = list.first
        gr.update(name_mn: ff.name_mn)
      end
    end



    # ali_filter_groups = AliFilterGroup.mn_change(true).name_mn_not_nil
    # ali_filter_groups.each do |gr|
    #   list = AliFilterGroup.mn_change(false).by_name(gr.name)
    #   list.update(name_mn: gr)
    # end
    #
    #

  end

  def translate
    translate = Google::Cloud::Translate.new version: :v2, project_id: 'market-1569213229660'

    ali_filter_groups = AliFilterGroup.name_mn_nil
    if ali_filter_groups.present?
      trans(translate, ali_filter_groups.first)
    end

    @count = 1000


    ali_filter_groups = AliFilterGroup.name_mn_nil
    if ali_filter_groups.present?
      trans(translate, ali_filter_groups.first)
    end

    ali_filters = AliFilter.name_mn_nil
    if ali_filters.present?
      trans_filter(translate, ali_filters.first)
    end

    ali_categories = AliCategory.name_mn_nil
    ali_categories.each do |category|
      translation = translate.translate category.name, to: "mn"
      category.update(name_mn: translation)
    end

    # ali_categories = AliCategory.all
    # ali_filter_group = AliFilterGroup.find(789)
    #
    # filter_group = CategoryFilterGroup.new(name_en: ali_filter_group.name, name: "test")
    # ali_filter_group.filters.each do |filter|
    #   filter_group.category_filters << CategoryFilter.new(name_en: 'image', name: "test", img: open(filter.img))
    # end
    # filter_group.save
  end

  def trans(translate, ali_filter_group)
    ali_filters = AliFilterGroup.name_mn_nil.by_name(ali_filter_group.name)

    translation = translate.translate ali_filter_group.name, to: "mn"
    ali_filters.update(name_mn: translation)


    ali_filter_groups = AliFilterGroup.name_mn_nil
    if ali_filter_groups.present?
      trans(translate, ali_filter_groups.first)
    end
  end

  def trans_filter(translate, ali_filter)
    ali_filters = AliFilter.name_mn_nil.by_name(ali_filter.name)
    logger.info('ali_filter.name =>' + ali_filter.name.to_s)
    translation = translate.translate ali_filter.name, to: "mn"
    ali_filters.update(name_mn: translation)


    list = AliFilter.name_mn_nil
    if list.present?
      trans_filter(translate, list.first)
    end
  end

end
