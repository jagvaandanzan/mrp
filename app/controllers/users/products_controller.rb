class Users::ProductsController < Users::BaseController
  load_and_authorize_resource

  before_action :set_product, only: [:edit, :update, :destroy, :show, :form_price]

  def index
    @code = params[:code]
    @name = params[:name]
    @price_min = params[:price_min]
    @price_max = params[:price_max]
    @customer_id = params[:customer_id]
    @category_id = params[:category_id]
    if @category_id.present?
      @product_category = ProductCategory.find(@category_id)
      @headers = ApplicationController.helpers.get_category_parents(@product_category)
      @headers = @headers.reverse
    end
    @products = Product.search(@code, @name, @price_min, @price_max, @customer_id, @category_id).page(params[:page])
  end

  def new
    @product = Product.new
    @product.code = ApplicationController.helpers.get_code(Product.last)
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :edit, id: @product.id, tab_index: 1
    else
      category_headers
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
      Rails.logger.info("product: #{@product.errors.full_messages}")
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
    @technical_spec_items = TechnicalSpecItem.by_group_id(params[:gr_id])
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
    params.require(:product).permit(:tab_index, :n_name, :n_model, :n_package, :n_material, :n_advantage, :brand_id, :category_id, :code, :is_own, :customer_id, option_rels: [])
  end

  def form_price_params
    params.require(:product).permit(:tab_index, :delivery_type, instruction_id: [], instruction_val: [],
                                    product_feature_items_attributes: [:id, :price, :p_6_8, :p_9_, :barcode, :c_balance, :_destroy])
  end

  def form_information_params
    params.require(:product).permit(:tab_index, :search_key, :description, :manufacturer_id, :expiry_date, :technical_specification_id,
                                    filters: [], specification_id: [], specification_val: [],
                                    product_instructions_attributes: [:id, :i_type, :description, :image, :video, :_destroy])
  end

  def form_image_video_params
    params.require(:product).permit(:tab_index, :picture, :photo_web, images_multi: [],
                                    product_feature_items_attributes: [:id, :same_item_id, :image, :real_img, :tab_index],
                                    product_images_attributes: [:id, :image, :_destroy],
                                    product_videos_attributes: [:id, :image, :video, :_destroy],
                                    product_photos_attributes: [:id, :photo, :_destroy])
  end

  def form_package_params
    params.require(:product_package).permit(:tab_index, :product_size, :bag, :package_unit, :width, :height, :length, :weight, :weight_unit, :gift_wrap)
  end
end
