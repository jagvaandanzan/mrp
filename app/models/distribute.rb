class Distribute
  include Singleton

  def create(salesman)

    return_signs = SalesmanReturnSign.by_salesman(salesman.id)
                       .by_user(nil)
    if return_signs.present?
      [422, I18n.t('errors.messages.return_request_not_confirmed')]
    else
      sale_items = ProductSaleItem.sale_available(salesman.id)
      if sale_items.present?
        [422, I18n.t('errors.messages.you_have_a_balance')]
      else
        travel_config = TravelConfig.get_last
        product_sales = ProductSale.by_salesman_nil
                            .by_delivery_end(Time.current.beginning_of_minute + 2.hours)

        location_ids = product_sales.map(&:location_id).to_a
        if location_ids.length == 0
          [422, I18n.t('errors.messages.not_have_a_product_sale')]
        else
          location_ids.unshift(1) # Агуулахаас эхлэнэ
          # [1, 2687, 3727, 3, 16, 7, 2823]

          locations = Location.search_by_ids(location_ids)
          location_travels = save_travels(locations)

          hash_location_travels = location_travels.map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h
          routing = vrptw(location_ids, hash_location_travels).map(&:to_i)
          Rails.logger.info("routing = #{routing}")
          # routing = [138, 0, 4, 3, 1, 5, 6, 2, 0].map(&:to_i)

          max_travel = travel_config.max_travel
          waiting_time = travel_config.waiting_time # хүртгэлт хооронд хүлээх минут

          travel = SalesmanTravel.new
          travel.salesman = salesman
          travel.distance = routing[0]
          travel_duration = 0
          loc_from_id = 1
          routing.each_with_index {|r, i|
            if i > 1 && r > 0
              product_sale = product_sales[r - 1]
              location = product_sale.location
              location_travel = hash_location_travels[loc_from_id.to_s + '-' + location.id.to_s]
              loc_from_id = location.id

              travel_route = SalesmanTravelRoute.new
              travel_route.queue = i - 2
              travel_route.distance = location_travel.distance
              travel_route.duration = location_travel.duration + waiting_time
              travel_duration += travel_route.duration
              travel_route.salesman_travel = travel
              travel_route.location = location
              travel_route.product_sale = product_sale

              travel.salesman_travel_routes << travel_route

              if travel_duration > max_travel
                break
              end

            end
          }
          travel.duration = travel_duration
          travel.save

          routing.each_with_index {|r, i|
            if i > 1 && r > 0
              product_sale = product_sales[r - 1]
              product_sale.update_column(:salesman_travel_id, travel.id)
            end
          }
          travel.send_notification

          [201, 'created', travel]
        end
      end
    end

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