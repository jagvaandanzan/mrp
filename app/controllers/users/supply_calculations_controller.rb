class Users::SupplyCalculationsController < Users::BaseController

  def supply_orders
    month_1 = Time.current.beginning_of_month
    @by_start = params[:by_start].presence || month_1.strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || (month_1 + 1.month).strftime("%Y/%m/%d")
  end

  def purchased_er
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @pur_products = ProductSupplyFeature
                  .by_date(@by_start, @by_end)
                  .purchased_er
                  .page(params[:page])
    @pur_products_x = ProductSupplyFeature
                      .by_date(@by_start, @by_end)
                      .purchased_er

    respond_to do |format|
      format.xlsx{
        render template: 'users/supply_calculations/purchased_er', xlsx: 'Эрээнд_ирээгүй_бараа'
      }
      format.html {render :purchased_er}
    end
  end

  def received_er
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @er_products = ProductSupplyFeature.received_er(@by_start, @by_end).page(params[:page])
    @er_products_x = ProductSupplyFeature.received_er(@by_start, @by_end)
    respond_to do |format|
      format.xlsx{
        render template: 'users/supply_calculations/received_er', xlsx: 'Эрээнд_эрсэн_бараа'
      }
      format.html {render :received_er}
    end
  end

  def ship_ub
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @ub_products = ProductSupplyFeature.ship_ub(@by_start, @by_end)
                                       .page(params[:page])
    @ub_products_x = ProductSupplyFeature.ship_ub(@by_start, @by_end)
    respond_to do |format|
      format.xlsx{
        render template: 'users/supply_calculations/ship_ub', xlsx: 'Улаанбаатарлуу_ачуулсан_бараа'
      }
      format.html {render :ship_ub}
    end
  end

  def income_products
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_nil = params[:by_nil]
    @income_products = ProductIncomeProduct.by_date(@by_start, @by_end)
                           .by_calc_nil(@by_nil)
                           .group("product_income_products.id")
                           .date_desc
                           .page(params[:page])

  end

  def for_invoice
    month_1 = Time.current.beginning_of_month
    @by_start = params[:by_start].presence || month_1.strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || (month_1 + 1.month).strftime("%Y/%m/%d")
    @by_code = params[:by_code]
    @product_incomes = ProductIncome.search(@by_code, @by_start, @by_end)
                                   .page(params[:page])
  end

  def set_all_calculated
    data = []
    item = ProductIncomeItem.by_income_product_id(params[:id])
    logistic = Logistic.find(4)
    item.each do |income_item|
      json = nil
    income_item.update_columns(calculated: params[:clarify] == "true" ? nil : params[:date], clarify: params[:clarify], description: params[:description])

    ip = income_item.product_income_product
    shipping_ub_product = ip.shipping_ub_product
    shipping_ub_sample = ip.shipping_ub_sample
    shipping_er = ip.shipping_er

    price = income_item.supply_feature.price_lo * income_item.quantity

    price += (shipping_er.per_price * income_item.quantity) if shipping_er.present?

    if shipping_ub_product.present? || shipping_ub_sample.present?
      per_cargo = shipping_ub_product.present? ? shipping_ub_product.per_price : shipping_ub_sample.per_cost
      price += (per_cargo * income_item.quantity)
    end

    if income_item.logistic_balance.present?
      if income_item.calculated.present?
        income_item.logistic_balance.update_columns(price: price,
                                                    date: income_item.calculated)
      else
        income_item.logistic_balance.destroy
      end
    else
      if income_item.calculated.present?
        LogisticBalance.create(logistic: logistic,
                               product_income_item: income_item,
                               price: price,
                               date: income_item.calculated)
      end
    end

      data << {id: income_item.id, calculated: income_item.calculated.present? ? income_item.calculated.strftime('%F') : income_item.description, clarify: params[:clarify]}
    end
    render json: data
  end

  #array zarlaj bgad rendereer butsaa tgd income deeree irsen dataga each hiiged gargaj aw inspect bas hii

  def set_calculated
    income_item = ProductIncomeItem.find(params[:id])
    income_item.update_columns(calculated: params[:clarify] == "true" ? nil : params[:date], clarify: params[:clarify], description: params[:description])
    logistic = Logistic.find(4)

    ip = income_item.product_income_product
    shipping_ub_product = ip.shipping_ub_product
    shipping_ub_sample = ip.shipping_ub_sample
    shipping_er = ip.shipping_er

    price = income_item.supply_feature.price_lo * income_item.quantity

    price += (shipping_er.per_price * income_item.quantity) if shipping_er.present?

    if shipping_ub_product.present? || shipping_ub_sample.present?
      per_cargo = shipping_ub_product.present? ? shipping_ub_product.per_price : shipping_ub_sample.per_cost
      price += (per_cargo * income_item.quantity)
    end

    if income_item.logistic_balance.present?
      if income_item.calculated.present?
        income_item.logistic_balance.update_columns(price: price,
                                                    date: income_item.calculated)
      else
        income_item.logistic_balance.destroy
      end
    else
      if income_item.calculated.present?
        LogisticBalance.create(logistic: logistic,
                               product_income_item: income_item,
                               price: price,
                               date: income_item.calculated)
      end
    end

    render json: {calculated: income_item.calculated.present? ? income_item.calculated.strftime('%F') : income_item.description, clarify: params[:clarify]}
  end

end
