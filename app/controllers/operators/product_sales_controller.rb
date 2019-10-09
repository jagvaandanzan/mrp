class Operators::ProductSalesController < Operators::BaseController
  before_action :set_product_sale, only: [:edit, :update, :show]

  def index
    @code = params[:code]
    @status_id = params[:status_id]
    @location_id = params[:location_id]
    @phone = params[:phone]
    @start = params[:start]
    @finish = params[:finish]

    @product_sales = ProductSale.search(@code, @start, @finish, @phone, @status_id, @location_id).page(params[:page])
  end

  def new
    @product_sale = ProductSale.new
    @product_sale.code = ApplicationController.helpers.get_code(ProductSale.last)
    # Шинэ захиалга үүсгэх үед + товч дарагдсан гарч ирэх
    @product_sale.product_sale_items.push(ProductSaleItem.new)
    @product_sale.sale_date = Time.current
    @product_sale.sale_date_end = @product_sale.sale_date
  end

  def search_locations
    @list = Location.search_by_name(params[:text])
    @select_id = params[:id]

    respond_to do |format|
      format.js {render 'shared/search_results'}
    end
  end

  def create
    @product_sale = ProductSale.new(product_sale_params)
    @product_sale.created_operator = current_operator

    if @product_sale.status.present? && @product_sale.status.alias == "approved"
      @product_sale.approved_operator = current_operator
      @product_sale.approved_date = Time.current
    end

    if @product_sale.save
      @product_sale_status_log = ProductSaleStatusLog.new
      @product_sale_status_log.product_sale = @product_sale
      @product_sale_status_log.operator = current_operator
      @product_sale_status_log.status = @product_sale.status
      @product_sale_status_log.note = @product_sale.status_note

      if @product_sale_status_log.save
        flash[:success] = t('alert.saved_successfully')
      else
        flash[:success] = t('alert.info_updated')
      end

      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_sale.attributes = product_sale_params

    if @product_sale.status.present? && @product_sale.status.alias == "approved"
      @product_sale.approved_operator = current_operator
      @product_sale.approved_date = Time.current
    end

    if @product_sale.save
      @product_sale_status_log = ProductSaleStatusLog.new
      @product_sale_status_log.product_sale = @product_sale
      @product_sale_status_log.operator = current_operator
      @product_sale_status_log.status = @product_sale.status
      @product_sale_status_log.note = @product_sale.status_note

      if @product_sale_status_log.save
        flash[:success] = t('alert.info_updated')
      else
        flash[:success] = t('alert.info_updated')
      end

      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def show
  end

  def get_sub_status
    @subs = nil
    if params[:parent_id].present?
      @subs = ProductSaleStatus.search(params[:parent_id], "operator")
    end

    render json: {childrens: @subs}
  end

  def get_product_features
    @features = []
    @price = 0
    if params[:product_id].present?
      product = Product.find(params[:product_id])
      @price = product.sale_price if product.present? && product.sale_price.present?

      @featureRels = ProductFeatureRel.search(params[:product_id])

      @featureRels.each do |rel|
        @features.push({id: rel.id, name: rel.rel_names, price: rel.sale_price})
      end
    end

    render json: {price: @price,
                  childrens: @features}
  end

  private

  def set_product_sale
    @product_sale = ProductSale.find(params[:id])
  end

  def product_sale_params
    params.require(:product_sale)
        .permit(:code, :sale_date, :sale_date_end, :phone, :location_id, :building_code, :loc_note,
                # :delivery_date,
                :payment_delivery, :payment_account,
                :status_id, :status_note,
                product_sale_items_attributes: [:id, :product_id, :product_feature_rel_id, :quantity, :price, :bonus, :_destroy])
  end
end
