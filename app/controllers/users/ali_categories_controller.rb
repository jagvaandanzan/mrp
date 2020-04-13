# rails s -p 3000 -P 42342
# rails s -e production -p 3000 -P 42342
class Users::AliCategoriesController < Users::BaseController
  before_action :set_ali_category, only: [:show, :edit, :update, :form_filter, :update_filter, :destroy, :set_prod]

  def index
    @ali_categories = AliCategory.parent_nil
                          .page(params[:page])
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
    ali_c = 0
    if !@ali_category.prod_was && @ali_category.prod
      ali_c += 1
    end

    @ali_category.sub_categories.each do |sub_category|
      if !sub_category.prod_was && sub_category.prod
        ali_c += 1
      end
    end

    if ali_c > 0
      user = current_user
      user.update(ali_c: user.ali_c + ali_c)
    end

    Rails.logger.debug(@ali_category.prod_was.to_s + "==>" + @ali_category.prod.to_s)
    if @ali_category.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :show, id: @ali_category.id
    else
      render 'edit'
    end
  end

  def form_filter
  end

  def update_filter
    @ali_category.attributes = form_filter_params

    ali_g = 0
    ali_f = 0
    @ali_category.ali_filter_groups.each do |gr|
      if !gr.prod_was && gr.prod
        ali_g += 1
      end
      gr.ali_filters.each do |ff|
        if !ff.prod_was && ff.prod
          ali_f += 1
        end
      end
    end

    if ali_g > 0 || ali_f > 0
      user = current_user
      user.update(ali_g: user.ali_g + ali_g, ali_f: user.ali_f + ali_f)
    end

    if @ali_category.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :show, id: @ali_category.id
    else
      render 'form_filter'
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
      ali_filters = AliFilterGroup
                        .mn_change(false)
                        .by_name(name)
    else
      ali_filters = AliFilter
                        .mn_change(false)
                        .by_name(name)
    end
    count = ali_filters.count
    ali_filters.update(name_mn: name_mn, mn_change: true, prod: true)

    render json: {status: "#{name} => #{name_mn} = #{count}, #{t('alert.saved_successfully')}"}
  end

  private

  def set_ali_category
    @ali_category = AliCategory.find(params[:id])
  end

  def ali_category_params
    params.require(:ali_category).permit(:name, :name_mn, :prod,
                                         sub_categories_attributes: [:id, :name, :name_mn, :prod, :_destroy])
  end

  def form_filter_params
    params.require(:ali_category).permit(ali_filter_groups_attributes: [:id, :name, :name_mn, :prod, :_destroy,
                                                                        ali_filters_attributes: [:id, :name, :name_mn, :prod, :_destroy]])
  end
end
