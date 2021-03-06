class Users::ProductFeatureItemsController < Users::BaseController
  before_action :set_feature_item, only: [:destroy]

  def new
    @feature_item = ProductFeatureItem.new
    @feature_item.product_id = params[:product_id]
    @feature_item.barcode = params[:barcode] if params[:barcode].present?
    @feature_item.price = params[:price] if params[:price].present?
    @feature_item.balance = params[:balance] if params[:balance].present?
    location_balances = params[:location_balance]
    if location_balances.present?
      lbs = location_balances.split('#')
      lbs.each do |lb|
        locs = lb.split('=')
        loc = locs[0]
        q = locs[1].to_i
        index_x = loc.index('x')
        index_y = loc.index('y')
        index_z = loc.index('z')

        x = loc[(index_x + 1)..(index_y - 1)].to_i
        y = loc[(index_y + 1)..(index_z - 1)].to_i
        z = loc.from(index_z + 1).to_i

        @feature_item.product_location_balances << ProductLocationBalance.new(x: x, y: y, z: z,
                                                                              quantity: q)
      end
    end
    respond_to do |format|
      format.js {render 'feature_add_ajax', locals: {hide_modal: false}}
    end
  end

  def create
    @feature_item = ProductFeatureItem.new(feature_item_params)
    @feature_item.is_add = true
    respond_to do |format|
      format.js {
        render 'feature_add_ajax', locals: {hide_modal: @feature_item.save}
      }
    end
  end

  def destroy
    @feature_item
    same_id_features = ProductFeatureItem.by_same_id(@feature_item.id)
    if same_id_features.present?
      same_id_feature = same_id_features.first
      same_id_feature.update_column(:same_item_id, nil)
    end

    @feature_item.destroy

    render json: {success: !@feature_item.errors.present?, errors: @feature_item.errors.full_messages}
  end

  def balance
    @code = params[:code]
    @name = params[:name]
    @balance = params[:balance]
    @barcode = params[:barcode]
    @desk = params[:desk]
    @customer_id = params[:customer_id]
    @category_id = params[:category_id]
    @storeroom_id = params[:storeroom_id]
    if @category_id.present?
      @product_category = ProductCategory.find(@category_id)
      @headers = ApplicationController.helpers.get_category_parents(@product_category)
      @headers = @headers.reverse
    end
    products = Product
                   .order_by_name
                   .by_not_draft
                   .s_by_code(@code)
                   .s_by_name(@name)
                   .by_customer(@customer_id)
                   .by_category(@category_id)
                   .by_barcode(@barcode)
                   .by_desk(@desk)
    if @storeroom_id.present?
      if @storeroom_id.to_i == 1
        products = products.by_balance(@balance)
      else
        @balance = "true"
        products = products.by_store_room(@storeroom_id)
      end
    else
      @balance = "true"
      products = products.any_balance
    end

    @product_count = products.length
    @total_pages = (@product_count / 20).to_i
    @total_pages += 1 if @product_count % 20 > 0

    @products = products.page(params[:page]).per(20)
  end

  def get_feature_items
    @storeroom_id = params[:storeroom_id]
    if @storeroom_id.present?
      @storeroom = Storeroom.find(@storeroom_id)
      @product_feature_items = if @storeroom_id.to_i == 1
                                 product = Product.find(params[:product_id])
                                 product.product_feature_items
                               else
                                 ProductFeatureItem.by_product_id(params[:product_id])
                                     .by_storeroom(@storeroom_id)
                               end
    else
      @product_feature_items = ProductFeatureItem.by_product_id(params[:product_id])
    end
    respond_to do |format|
      format.js {render 'feature_items_ajax'}
    end
  end

  def set_balance
    if params[:id].present? && params[:id].to_i > 0
      product = Product.find(params[:id])
      if product.present?
        @code = product.code
      end
    end
  end

  def load_features
    product = Product.find(params[:product_id])

    @product_feature_items = product.product_feature_items
    respond_to do |format|
      format.js {render 'itoms_ajax'}
    end
  end

  def itoms
    code = params[:code]
    product = Product.find_by_code(code)

    if product.present?
      @name = product.name
      @product_id = product.id
      @product_feature_items = product.product_feature_items
    end

    respond_to do |format|
      format.js {render 'itoms_ajax'}
    end

  end

  def update_feature
    feature_item = ProductFeatureItem.find(params[:item_id])
    feature_item.is_update = true
    feature_item.barcode = params[:barcode]
    feature_item.price = params[:price]
    feature_item.p_6_8_p = params[:p_6_8_p]
    feature_item.p_6_8 = params[:p_6_8]
    feature_item.p_9_p = params[:p_9_p]
    feature_item.p_9_ = params[:p_9_]
    feature_item.init_bal = params[:init_bal].to_i

    if feature_item.init_bal > 0 && feature_item.product_balances.present? && feature_item.balance.present?
      not_init = feature_item.product_balances.not_init.sum(:quantity)
      feature_item.balance = feature_item.init_bal + not_init
    else
      feature_item.balance = params[:balance].to_i
    end

    feature_item.cost = params[:cost].to_i if params[:cost].present?
    if feature_item.init_bal > 0 || feature_item.balance > 0
      feature_item.product_location_balances.destroy_all
      feature_item.location_balances = params[:location_balance]
    end
    feature_item.save
    render json: {success: !feature_item.errors.present?, errors: feature_item.errors.full_messages}
  end

  private

  def set_feature_item
    @feature_item = ProductFeatureItem.find(params[:id])
  end

  def feature_item_params
    params.require(:product_feature_item).permit(:product_id, :option1_id, :option2_id, :same_item_id, :image, :real_img, :price, :p_6_8_p, :p_9_p, :barcode, :balance,
                                                 product_location_balances_attributes: [:id, :x, :y, :z, :quantity, :_destroy])
  end
end
