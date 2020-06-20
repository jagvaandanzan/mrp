class Users::ProductsController < Users::BaseController
  load_and_authorize_resource

  before_action :set_product, only: [:edit, :update, :destroy, :show, :form_price]

  def index
    @search_name = params[:product_name]
    @products = Product.search(@search_name).page(params[:page])
  end

  def new
    @product = Product.new
    @product.code = ApplicationController.helpers.get_code(Product.last)
    @product.product_names << [ProductName.new(n_type: :m_name),
                               ProductName.new(n_type: :m_number),
                               ProductName.new(n_type: :packaging),
                               ProductName.new(n_type: :brand),
                               ProductName.new(n_type: :material),
                               ProductName.new(n_type: :advantages)]
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :edit, id: @product.id, tab_index: 1
    else
      render 'new'
    end
  end

  def show
    category_headers
  end

  def edit
    category_headers
    unless @product.product_package.present?
      @product.product_package = ProductPackage.new
    end
    unless @product.product_names.present?
      @product.product_names << [ProductName.new(n_type: :m_name),
                                 ProductName.new(n_type: :m_number),
                                 ProductName.new(n_type: :packaging),
                                 ProductName.new(n_type: :brand),
                                 ProductName.new(n_type: :material),
                                 ProductName.new(n_type: :advantages)]
    end
  end

  def update
    @product.attributes = product_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      category_headers
      render 'edit'
    end
  end

  def destroy
    @product.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def get_product_category_children
    categories = []
    if params[:parent_id].present?
      categories = ProductCategory.search(params[:parent_id])
    end

    render json: {childrens: categories}

  end

  def form_price
    @product.attributes = form_price_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :edit, id: @product.id, tab_index: 2
    else
      category_headers
      render 'edit'
    end
  end

  def form_information
    @product.attributes = form_information_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :edit, id: @product.id, tab_index: 3
    else
      category_headers
      render 'edit'
    end
  end

  def form_image_video
    @product.attributes = form_image_video_params
    if @product.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :edit, id: @product.id, tab_index: 4
    else
      category_headers
      render 'edit'
    end
  end

  def form_package
    @product.product_package.attributes = form_package_params
    @product.tab_index = @product.product_package.tab_index
    if @product.product_package.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      category_headers
      render 'edit'
    end
  end

  def technical_spec_items
    @technical_spec_items = TechnicalSpecItem.by_group_id(params[:gr_id]).order_specification
    respond_to do |format|
      format.js {render 'technical_spec_item_ajax'}
    end
  end

  private

  def category_headers
    @product.tab_index = params[:tab_index] if params[:tab_index].present?
    @headers = ApplicationController.helpers.get_category_parents(@product.category)
    @headers = @headers.reverse
    @product.option_rels = @product.product_feature_option_rels.map {|i| i.feature_option_id.to_s}.to_a
    @product.filters = @product.product_filters.map {|i| i.category_filter_id.to_s}.to_a
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:tab_index, :name_en, :name_cn, :category_id, :code, :is_own, :customer_id, option_rels: [],
                                    product_names_attributes: [:id, :name, :n_type, :_destroy])
  end

  def form_price_params
    params.require(:product).permit(:tab_index, :delivery_type, instruction_id: [], instruction_val: [],
                                    product_feature_items_attributes: [:id, :price, :p_6_8, :p_9_, :c_balance])
  end

  def form_information_params
    params.require(:product).permit(:tab_index, :search_key, :description, :brand_id, :manufacturer_id, :expiry_date, :technical_specification_id,
                                    filters: [], specification_id: [], specification_val: [],
                                    product_instructions_attributes: [:id, :i_type, :description, :image, :video, :_destroy])
  end

  def form_image_video_params
    params.require(:product).permit(:tab_index, :picture, :photo_web,
                                    product_feature_items_attributes: [:id, :same_item_id, :image, :tab_index],
                                    product_images_attributes: [:id, :image, :_destroy],
                                    product_videos_attributes: [:id, :video, :_destroy],
                                    product_photos_attributes: [:id, :photo, :_destroy])
  end

  def form_package_params
    params.require(:product_package).permit(:tab_index, :product_size, :package_unit, :width, :height, :length, :weight, :weight_unit, :gift_wrap)
  end
end
