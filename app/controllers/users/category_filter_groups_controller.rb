class Users::CategoryFilterGroupsController < Users::BaseController
  authorize_resource
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy]


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

  def index
    @filter_name = params[:filter_name]
    @filter_groups = CategoryFilterGroup.search(@filter_name).page(params[:page])
    cookies[:category_filter_page_number] = params[:page]
  end

  def new
    @filter_group = CategoryFilterGroup.new
  end

  def create
    @filter_group = CategoryFilterGroup.new(filter_group_params)
    if @filter_group.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      logger.debug(@filter_group.errors.full_messages)
      render 'new'
    end
  end

  def edit
  end

  def show
  end

  def update
    @filter_group.attributes = filter_group_params
    @filter_group.prod = true
    if @filter_group.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @filter_group.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_filter_group
    @filter_group = CategoryFilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:category_filter_group).permit(:name,
                                                  category_filters_attributes: [:id, :name, :_destroy])
  end
end
