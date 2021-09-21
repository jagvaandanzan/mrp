require 'roo'

spreadsheet = Roo::Spreadsheet.open("#{Rails.root}/public/Book2.xlsx") # open spreadsheet
header = spreadsheet.row(1)
(2..spreadsheet.last_row).map do |i|
  row = Hash[[header, spreadsheet.row(i)].transpose]
  puts "#{row['C2QTY']} = "
  if row['C2QTY'].present?
    item = ProductFeatureItem.find_by_barcode(row['BARCODE'])
    if item.present?
      has_location = false
      balance = row['C2QTY'].to_i
      if balance > 0
        puts "feature_item: #{item.id}, balance => #{balance}"
        item.update_column(:init_bal, balance)
        not_init = item.product_balances.not_init.sum(:quantity)

        ProductBalance.create(product_id: item.product_id, feature_item: item, quantity: balance)
        balance += not_init

        if balance > 0
          location = row['TAVIUR1']
          if location.present?
            loc = location.downcase
            if loc.length > 5
              index_x = loc.index('x')
              index_y = loc.index('y')
              index_z = loc.index('z')
              if !index_x.nil? && !index_y.nil? && !index_z.nil?
                x = loc[(index_x + 1)..(index_y - 1)].to_i
                y = loc[(index_y + 1)..(index_z - 1)].to_i
                z = loc.from(index_z + 1).to_i

                product_locations = ProductLocation.by_xyz(x, y, z)
                product_location = if product_locations.present?
                                     product_locations.first
                                   else
                                     ProductLocation.create(x: x, y: y, z: z)
                                   end
                ProductLocationBalance.create(product_location: product_location,
                                              product_feature_item: item,
                                              quantity: balance)
                has_location = true
              end
            end
          end
        end

        unless has_location
          ProductLocationBalance.create(product_location_id: 1,
                                        product_feature_item: item,
                                        quantity: balance) if balance > 0
        end
      else
        item.update_columns(init_bal: 0, balance: 0)
      end
      if row['PRICE'].present?
        price = row['PRICE'].to_i
        item.update_column(:price, price) if price > 0
      end
    else
      balance = row['C2QTY'].to_i
      if balance > 0
        puts "feature_temp: #{row['BARCODE']}"
        TmpProduct.create(name: row['DESCRIPTION'],
                          feature: row['SERIALNO'],
                          barcode: row['BARCODE'],
                          balance: balance,
                          price: row['PRICE'],
                          serial_id: row['SERIAL_ID'],
                          location: row['TAVIUR1'])
      end
    end
  end
end
