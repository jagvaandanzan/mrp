class SalesmanMoney
  include Singleton

  def calc(date, salesman_id)

    product_sales = ProductSale.joins(:salesman_travel)
                        .where("salesman_travels.salesman_id = ?", salesman_id)
                        .where('salesman_travels.delivery_at >= ?', date)
                        .where('salesman_travels.delivery_at < ?', date + 1.days)
                        .where('product_sales.status_id >= ? AND product_sales.status_id <= ? ', 12, 14)

    q = 0 # Нийт тоо ширхэг
    price = 0 #Нийт дүн
    back_sum = 0 #Буцаалт
    acc_sum = 0 #Дансаар
    cash_sum = 0 #Бэлнээр
    bought_sum = 0

    product_sales.each do |product_sale|
      sale_items = product_sale.product_sale_items.not_nil_bought_quantity
      acc_sum += product_sale.paid if product_sale.paid.present?
      if sale_items.present?
        sale_items.each {|item|
          q += item.bought_quantity
          price += item.bought_price
          bought_sum += item.bought_price
        }
      end
      # Буцаалт, солилт
      if product_sale.parent_id.present?
        b_price = product_sale.return_price
        if bought_sum == 0 # Хэрэв буцаалт бол
          back_sum += b_price
        else # Солилт
          p = bought_sum - b_price - (product_sale.paid.presence || 0)
          if p < 0
            p *= -1
            back_sum += p
          else # Хэрэглэгчийн төлөх мөнгө үлдсэн бол
            cash_sum += p
          end
        end
      else
        p = product_sale.paid.present? ? bought_sum - product_sale.paid : bought_sum
        cash_sum += p
      end

      bought_sum = 0
    end

    sale_directs = ProductSaleDirect.by_salesman_id(salesman_id)
                       .date_between(date)
    p = sale_directs.sum(:sum_price)
    q += sale_directs.sum(:quantity)
    price += p
    cash_sum += p

    # logger.info("Нийт: #{price}")
    # logger.info("Буцаалт: #{back_sum}")
    # logger.info("Дансаар: #{acc_sum}")
    # logger.info("Бэлнээр: #{cash_sum}")
    # logger.info("ТҮГЭЭГЧЭЭС АВАХ БЭЛЭН МӨНГӨ: #{cash_sum - back_sum}")
    [q, price, back_sum, acc_sum, cash_sum, cash_sum - back_sum]

  end
end


def vrptw(location_ids, hash_loc_travels) # return routing = [138, 0, 7, 4, 3, 1, 6, 10, 2, 9, 8, 5, 11, 0]
  # location_travels = LocationTravel.search(location_ids).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

  folder_path = "public/routing/"
  file_temp = "#{Time.zone.now.to_i}"
  file_name = "#{file_temp}_case.txt"
  File.open(folder_path + file_name, "w")

  location_ids.each {|r_key|
    row_text = ""
    location_ids.each {|key|
      if r_key == key
        row_text += "0, "
      else
        location_travel = hash_loc_travels[r_key.to_s + '-' + key.to_s]
        if location_travel.present?
          row_text += location_travel.duration.to_s + ", "
        else
          row_text += "0, "
        end
      end
    }
    File.open(folder_path + file_name, "a") do |line|
      line.puts row_text.slice(0, row_text.length - 2)
    end
  }

  system "cd " + folder_path + " && python tsp.py " + file_temp

  result_path = folder_path + "#{file_temp}_result.txt"

  # result үүсэх хүртэл 6 сек хүлээнэ
  second = 0
  until File.exists?(result_path) || second == 6
    sleep(1)
    second += 1
  end

  if second == 6
    []
  else
    result_data = File.read(result_path)
    result_data.split(',').map(&:to_i)
  end

  # if result_data == "error"
  #   routing = result_data
  # else
  #   # salesman р үзээд батгахгүй бол 2 машинаас эхлэж явуулж үзнэ
  #   routing = extra_result("tsp", max_travel, result_data)
  #
  #   if routing.length == 0 # багтаагүй байна
  #     vehicle = 2
  #     while routing != "error" && routing.length == 0
  #       FileUtils.rm(result_path)
  #       system "cd " + folder_path + " && python vrp.py " + max_travel.to_s + " " + file_temp + " " + vehicle.to_s
  #
  #       second = 0
  #       until File.exists?(result_path) || second == 6
  #         sleep(1)
  #         second += 1
  #       end
  #
  #       result_data = if second == 6
  #                       "error"
  #                     else
  #                       File.read(result_path)
  #                     end
  #
  #       if result_data == "error"
  #         routing = result_data
  #       else
  #         routing = extra_result("vrp", max_travel, result_data)
  #       end
  #
  #       vehicle += 1 # машины тоог нэмж үзнэ
  #     end
  #
  #   end
  # end
  # TODO буцаах устгадаг болгох
  # FileUtils.rm [folder_path + file_name, result_path]

end

def extra_result(type, max_travel, result)
  if type == "tsp"
    array = result.split(',').map(&:to_i)
    if max_travel >= array[0]
      return array
    end

  else # vrp

    lines = result.split(/\n+/)
    min_max = lines[lines.length - 1].split(',').map(&:to_i)
    if max_travel >= min_max[0]
      max_routing = 0
      max_at_index = 0
      # олон хүргэлттэйг нь авна
      lines.each_with_index do |line, index|
        if index != lines.length - 1 # хамгийн сүүлийн мах мин учир тооцохгүй
          array = line.split(',').map(&:to_i)
          if max_travel >= array[1] && max_routing < array.length
            max_at_index = index
            max_routing = array.length
          end
        end
      end
      # олон хүргэлттэйг г олсон
      array = lines[max_at_index].split(',').map(&:to_i)
      return array.slice(1, array.length - 1)
    end

  end

  []
end

def save_travels(locations)
  # print ''
  # STDOUT.flush
  new_location_travels = []

  length = locations.length #locations.map(&:id).to_a
  # өмнө нь авсан зайнуудыг авна
  location_travels = LocationTravel.search(locations.map(&:id).to_a).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

  len_ori = 0 # google origins, destinations max 25 elements

  max_dis = length > 25 ? 25 : length
  max_ori = (100 / max_dis).to_i
  Rails.logger.info("distributing.max_ori = #{max_ori} / #{length}")
  Rails.logger.info("distributing.max_dis = #{max_dis} / #{length}")
  while len_ori < length do
    ori_locations = locations.slice(len_ori, max_ori)
    len_ori += ori_locations.length
    # Rails.logger.info("distributing.ori_locations = #{ori_locations.map(&:id).to_a}")
    # Rails.logger.info("distributing.len_ori = #{len_ori}")

    len_dis = 0
    while len_dis < length do
      dis_locations = locations.slice(len_dis, max_dis)
      len_dis += dis_locations.length
      # Rails.logger.info("distributing.len_dis = #{len_dis}")

      matrix_locations = []
      origins = ""
      destinations = ""

      ori_locations.each {|location|
        dis_locations.each {|loc_dis|
          matrix_locations.push([location.id, loc_dis.id])
        }
      }

      ori_locations.each {|location|
        if origins.length > 0
          origins += "|"
        end
        origins += location.latitude.to_s + "," + location.longitude.to_s
      }

      dis_locations.each {|location|
        if destinations.length > 0
          destinations += "|"
        end
        destinations += location.latitude.to_s + "," + location.longitude.to_s
      }

      # Rails.logger.debug("distributing.matrix_locations = #{matrix_locations.to_s}")

      url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" + origins + "&destinations=" + destinations + "&key=" + ENV['GOOGLE_MAP_KEY']
      # Rails.logger.debug("distributing.url = #{url}")

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      # Rails.logger.debug("distributing.response = #{response.body}")

      json = JSON.parse(response.body)
      m_index = 0 # matrix_index
      ori_locations.each_index {|index|
        elements = json['rows'][index]['elements']
        elements.each {|e|
          matrix_location = matrix_locations[m_index]
          if matrix_location[0] != matrix_location[1]
            if e['status'].to_s == "OK"

              hash_travel = location_travels[matrix_location[0].to_s + '-' + matrix_location[1].to_s]
              meter = e['distance']['value']
              minute = (e['duration']['value'] / 60).to_i

              if hash_travel.present?
                hash_travel.distance = meter
                hash_travel.duration = minute
                hash_travel.save
                new_location_travels << hash_travel
              else
                location_travel = LocationTravel.create(location_from_id: matrix_location[0], location_to_id: matrix_location[1], distance: meter, duration: minute)
                new_location_travels << location_travel
              end
              # Rails.logger.debug("meter=" + e['distance']['value'].to_s)
              # Rails.logger.debug("minute=" + e['duration']['value'].to_s)
            end
          end

          m_index += 1
        }
      }

    end
  end

  new_location_travels
end