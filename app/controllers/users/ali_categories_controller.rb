# rails s -p 3000 -P 42342
class Users::AliCategoriesController < Users::BaseController
  before_action :set_ali_category, only: [:show, :edit, :update, :destroy, :set_prod]

  def index
    @prod = params[:prod]
    @ali_categories = AliCategory.is_check.check_prod(@prod).page(params[:page])
    cookies[:ali_categories_page_number] = params[:page]
  end

  def new
    @ali_category = AliCategory.new
  end

  def create
    @ali_category = AliCategory.new(ali_category_params)
    if @ali_category.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      logger.debug(@ali_category.errors.full_messages)
      render 'new'
    end
  end

  def edit
  end

  def show
  end

  def update
    @ali_category.attributes = ali_category_params
    if @ali_category.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @ali_category.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def set_prod
    @ali_category.update(prod: true)
    render json: {status: 'ok'}
  end

  def set_name_as_filter
    name = params[:name]
    name_mn = params[:name_mn]

    if params[:ftype] == "group"
      ali_filters = AliFilterGroup.name_mn_nil
                        .mn_change(false)
                        .by_name(name)
    else
      ali_filters = AliFilter.name_mn_nil
                        .mn_change(false)
                        .by_name(name)
    end
    count = ali_filters.count
    ali_filters.update(name_mn: name_mn, mn_change: true)

    render json: {status: "#{name} => #{name_mn} = #{count}, #{t('alert.saved_successfully')}"}
  end

  private

  def set_ali_category
    @ali_category = AliCategory.find(params[:id])
  end

  def ali_category_params
    params.require(:ali_category).permit(:name, :name_mn, :prod,
                                         ali_filter_groups_attributes: [:id, :name, :name_mn, :_destroy,
                                                                        ali_filters_attributes: [:id, :name, :name_mn, :_destroy]])
  end
end
