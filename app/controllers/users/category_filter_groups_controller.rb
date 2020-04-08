class Users::CategoryFilterGroupsController < Users::BaseController
  authorize_resource
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy]


  require "google/cloud/translate"
  def translate
    translate = Google::Cloud::Translate.new version: :v2, project_id: 'market-1569213229660'

    ali_filter_groups = AliFilterGroup.name_mn_nil
    ali_filter_groups.each do |gr|
      translation = translate.translate gr.name, to: "mn"
      gr.update(name_mn: translation)
    end

    @count = ali_filter_groups.count
    # ali_categories = AliCategory.all
    # ali_filter_group = AliFilterGroup.find(789)
    #
    # filter_group = CategoryFilterGroup.new(name_en: ali_filter_group.name, name: "test")
    # ali_filter_group.filters.each do |filter|
    #   filter_group.category_filters << CategoryFilter.new(name_en: 'image', name: "test", img: open(filter.img))
    # end
    # filter_group.save
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
