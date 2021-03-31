class Users::SupplyCalculationsController < Users::BaseController

  def supply_orders
    logistic = Logistic.find(4)
    @balance = logistic.balance
    month_1 = Time.current.beginning_of_month
    @by_start = params[:by_start].presence || month_1.strftime("%Y/%m/%d")
    @by_end = params[:by_end].presence || (month_1 + 1.month).strftime("%Y/%m/%d")
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
