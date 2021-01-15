class Logistics::ShippingUbsController < Logistics::BaseController
  before_action :set_shipping_ub, only: [:show, :edit, :update, :destroy]

  def index
    @product_name = params[:product_name]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @shipping_ubs = ShippingUb.search(@by_start, @by_end, @product_name).page(params[:page])
    cookies[:shipping_ub_page_number] = params[:page]
  end

  def new
    @shipping_ub = ShippingUb.new
    @shipping_ub.date = Time.current
    @shipping_ub.number = ApplicationController.helpers.last_number(ShippingUb)
    @shipping_ub.shipping_ub_boxes << ShippingUbBox.new
  end

  def create
    @shipping_ub = ShippingUb.new(shipping_ub_params)

    if @shipping_ub.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      logger.info("errors: #{@shipping_ub.errors.full_messages}")
      @shipping_ub.date = Time.current
      @shipping_ub.number = ApplicationController.helpers.last_number(ShippingUb)
      render 'new'
    end
  end

  def add_product
    @shipping_er_product = ShippingErProduct.find_to_ub(params[:id]).first
    @rows = params[:rows].to_i
    @box_r = params[:box_r].to_i - 1
    respond_to do |format|
      format.js {render 'logistics/shipping_ubs/add_product'}
    end
  end

  def show
  end

  def edit
    @shipping_ub.shipping_ub_boxes.each do |ub_box|
      ub_box.shipping_ub_products.each {|ub_product|
        ub_product.remainder = ub_product.shipping_er_product.quantity - ShippingUbProduct.sum_quantity_by_er_product(ub_product.shipping_er_product_id) + ub_product.quantity
      }
    end
  end

  def update
    @shipping_ub.attributes = shipping_ub_params
    if @shipping_ub.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @shipping_ub.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_shipping_ub
    @shipping_ub = ShippingUb.find(params[:id])
  end

  def shipping_ub_params
    params.require(:shipping_ub).permit(:date, :s_type, :description,
                                        shipping_ub_boxes_attributes: [:id, :_destroy,
                                                                       shipping_ub_products_attributes: [:id, :product_id, :shipping_er_product_id, :remainder, :quantity, :cargo, :cost, :_destroy]])
        .merge(:logistic => current_logistic)
  end
end