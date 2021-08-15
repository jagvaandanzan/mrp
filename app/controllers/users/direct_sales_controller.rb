class Users::DirectSalesController < Users::BaseController
  before_action :set_direct_sale, only: [:edit, :update, :show, :destroy]

  def index
    @start = params[:start]
    @finish = params[:finish]
    @product_name = params[:product_name]
    @id = params[:id]
    @sale_type = params[:sale_type]
    @phone = params[:phone]
    @tax = params[:tax].presence || false

    @direct_sales = DirectSale.search(@start, @finish, @id, @product_name, @sale_type, @phone, @tax).page(params[:page])
    cookies[:direct_sale_page_number] = params[:page]
  end

  def new
    @direct_sale = DirectSale.new
    @direct_sale.date = Time.current
    @direct_sale.code = DirectSale.all.count + 1
  end

  def create
    @direct_sale = DirectSale.new(direct_sale_params)

    if @direct_sale.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      @direct_sale.code = DirectSale.all.count + 1
      logger.debug(@direct_sale.errors.full_messages)
      render 'new'
    end
  end

  def edit
    @direct_sale.direct_sale_items.each do |item|
      item.remainder = item.feature_item.balance + item.quantity
    end
  end

  def destroy
    if @direct_sale.child.present?
      redirect_to action: :show, id: @direct_sale.id
    else
      @direct_sale.destroy!
      flash[:success] = t('alert.deleted_successfully')
      redirect_to action: 'index'
    end
  end

  def update
    @direct_sale.attributes = direct_sale_params

    if @direct_sale.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def show
  end

  def get_product_balance
    feature_item_id = params[:feature_item_id]
    feature_item = ProductFeatureItem.find(feature_item_id)

    desk = []
    ProductLocation.get_quantity(feature_item_id).each do |loc|
      desk << {id: loc.id, name: loc.name, balance: loc.quantity}
    end

    render json: {balance: feature_item.balance,
                  price: feature_item.price.presence || 0,
                  img: feature_item.img.present? ? feature_item.img.url : '/assets/no-image.png',
                  tumb: feature_item.img.present? ? feature_item.img.url(:tumb) : '/assets/no-image.png',
                  desk: desk}
  end

  private

  def set_direct_sale
    @direct_sale = DirectSale.find(params[:id])
  end

  def direct_sale_params
    params.require(:direct_sale)
        .permit(:date, :sale_type_id, :user_id, :purchaser_id, :phone, :price_type, :discount, :cost, :cost_note, :value, :tax,
                direct_sale_items_attributes: [:id, :product_id, :feature_item_id, :remainder, :product_location_id, :quantity, :price, :sum_price, :discount, :pay_price, :_destroy])
        .merge(owner: current_user)
  end

end
