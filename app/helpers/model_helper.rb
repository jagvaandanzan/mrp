module ModelHelper

  def feature_product_names(objs)
    n = ""
    objs.each_with_index do |obj, index|
      feature_item = obj.feature_item
      if index > 0
        n += ", "
      end
      n += "#{feature_item.product.code} #{obj.product_sale.phone} #{obj.quantity}ш"
    end
    n
  end
end
