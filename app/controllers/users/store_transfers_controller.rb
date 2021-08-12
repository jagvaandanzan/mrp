class Users::StoreTransfersController < Users::BaseController
  before_action :set_store_transfer, only: [:edit, :update, :show, :destroy]

  def index
    @start = params[:start]
    @finish = params[:finish]
    @product_name = params[:product_name]
    @store_to = params[:store_to]
    @store_from = params[:store_from]
    @user_id = params[:user_id]
    @value = params[:value]

    @store_transfers = StoreTransfer.search(@start, @finish, @product_name, @store_to, @store_from, @user_id, @value).page(params[:page])
    cookies[:store_transfer_page_number] = params[:page]
  end

  def new
    @store_transfer = StoreTransfer.new
    @store_transfer.date = Time.current
    @store_transfer.code = StoreTransfer.all.count + 1
    @store_transfer.store_from_id = 1
  end

  def create
    @store_transfer = StoreTransfer.new(store_transfer_params)

    if @store_transfer.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      @store_transfer.code = StoreTransfer.all.count + 1
      logger.debug(@store_transfer.errors.full_messages)
      render 'new'
    end
  end

  def edit
    if @store_transfer.store_from_id == 1
      @store_transfer.store_transfer_items.each do |item|
        item.remainder = item.feature_item.balance + item.quantity
      end
    else
      @store_transfer.store_transfer_items.each do |item|
        item.remainder = StoreTransferBalance.balance_sum(item.product_id, item.feature_item_id, @store_transfer.store_from_id) + item.quantity
      end
    end
  end

  def destroy
    if @store_transfer.child.present?
      redirect_to action: :show, id: @store_transfer.id
    else
      @store_transfer.destroy!
      flash[:success] = t('alert.deleted_successfully')
      redirect_to action: 'index'
    end
  end

  def update
    @store_transfer.attributes = store_transfer_params
    if @store_transfer.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def show
  end

  def get_product_features
    features = []
    price = 0
    img_url = "/images/orignal/missing.png"

    if params[:product_id].present?
      store_from_id = params[:store_from_id].to_i
      product = Product.find(params[:product_id])
      img_url = product.picture.url(:tumb) if product.picture.present?
      price = product.price if product.price.present?
      product.product_feature_items.each do |item|
        features.push({id: item.id, name: item.name, balance: store_from_id == 1 ? item.balance : StoreTransferBalance.balance_sum(params[:product_id], item.id, store_from_id), product: product.id})
      end
    end

    render json: {price: price, features: features, tumb: img_url}
  end

  def get_product_balance
    feature_item_id = params[:feature_item_id]
    feature_item = ProductFeatureItem.find(feature_item_id)
    store_from_id = params[:store_from_id].to_i
    render json: {balance: store_from_id == 1 ? feature_item.balance : StoreTransferBalance.balance_sum(params[:product_id], feature_item_id, store_from_id),
                  price: feature_item.price.presence || 0,
                  img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png',
                  tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png',
                  desk: feature_item.desk}
  end

  private

  def set_store_transfer
    @store_transfer = StoreTransfer.find(params[:id])
  end

  def store_transfer_params
    params.require(:store_transfer)
        .permit(:date, :store_from_id, :store_to_id, :value,
                store_transfer_items_attributes: [:id, :product_id, :feature_item_id, :remainder, :product_location_id, :quantity, :price, :sum_price, :description, :_destroy])
        .merge(user: current_user)
  end

end
