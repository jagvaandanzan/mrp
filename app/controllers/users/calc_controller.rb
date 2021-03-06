class Users::CalcController < Users::BaseController
  require "net/https"
  require "uri"

  def vrptw
    location = ProductLocation.find(1)
    travel = SalesmanTravel.find(1)
    travel.product_sales.each do |product_sale|
      product_sale.product_sale_items.each_with_index {|item, index|
        ProductWarehouseLoc.create(salesman_travel: travel,
                                   product: item.product,
                                   location: location,
                                   feature_item: item.feature_item,
                                   quantity: item.quantity,
                                   queue: index)
      }
    end
  end

  def vrptw12
    array_locations = [527, 2909, 2577, 842, 1885, 1149, 2919, 875, 2347, 31, 2749, 2034]
    routing = [138, 0, 7, 4, 3, 1, 6, 10, 2, 9, 8, 5, 11, 0]
    locations = []

    routing.each_with_index do |r, index|
      if index > 0
        loc = Location.find(array_locations[r])
        locations.push(loc)
      end

    end
    @distance = routing[0]
    @locations = locations

  end

  def vrptw1
    array_locations = [527, 2909, 2577, 842, 1885, 1149, 2919, 875, 2347, 31, 2749, 2034]
    location_travels = LocationTravel.search(array_locations).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

    folder_path = "public/routing/"
    file_temp = "#{Time.zone.now.to_i}"
    file_name = "#{file_temp}_case.txt"
    File.open(folder_path + file_name, "w")

    array_locations.each {|r_key|
      row_text = ""
      array_locations.each {|key|
        if r_key == key
          row_text += "0, "
        else
          location_travel = location_travels[r_key.to_s + '-' + key.to_s]
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

    second = 0
    until File.exists?(result_path) || second == 6
      sleep(1)
      second += 1
    end

    travel_config = TravelConfig.get_last
    max_travel = travel_config.max_travel

    result_data = if second == 6
                    "error"
                  else
                    File.read(result_path)
                  end

    if result_data == "error"
      routing = result_data
    else
      # salesman ?? ?????????? ?????????????????? ?????? 2 ???????????????? ?????????? ???????????? ????????
      routing = extra_result("tsp", max_travel, result_data)

      if routing.length == 0 # ?????????????????? ??????????
        vehicle = 2
        while routing != "error" && routing.length == 0
          FileUtils.rm(result_path)
          system "cd " + folder_path + " && python vrp.py " + max_travel.to_s + " " + file_temp + " " + vehicle.to_s

          second = 0
          until File.exists?(result_path) || second == 6
            sleep(1)
            second += 1
          end

          result_data = if second == 6
                          "error"
                        else
                          File.read(result_path)
                        end

          if result_data == "error"
            routing = result_data
          else
            routing = extra_result("vrp", max_travel, result_data)
          end

          vehicle += 1 # ???????????? ???????? ???????? ????????
        end

      end
    end

    FileUtils.rm [folder_path + file_name, result_path]

    routing
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
        # ???????? ?????????????????????? ???? ????????
        lines.each_with_index do |line, index|
          if index != lines.length - 1 # ?????????????? ?????????????? ?????? ?????? ???????? ??????????????????
            array = line.split(',').map(&:to_i)
            if max_travel >= array[1] && max_routing < array.length
              max_at_index = index
              max_routing = array.length
            end
          end
        end
        # ???????? ?????????????????????? ?? ??????????
        array = lines[max_at_index].split(',').map(&:to_i)
        return array.slice(1, array.length - 1)
      end

    end

    []
  end

  def save_travels(locations)
    # print ''
    # STDOUT.flush

    hash_locations = locations.map {|i| [i.id, i]}.to_h
    length = hash_locations.length #locations.map(&:id).to_a
    # ???????? ???? ?????????? ?????????????????? ????????
    location_travels = LocationTravel.search(hash_locations.keys).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

    len = 0 # google max 100 elements
    max_len = (100 / length).to_i
    while len < length do
      sub_locations = locations.slice(len, max_len)
      len += sub_locations.length

      matrix_locations = []
      origins = ""
      destinations = ""

      sub_locations.each {|location|
        hash_locations.each_key {|key|
          matrix_locations.push([location.id, key])
        }
      }

      sub_locations.each {|location|
        if origins.length > 0
          origins += "|"
        end
        origins += location.latitude.to_s + "," + location.longitude.to_s
      }

      hash_locations.each_value {|location|
        if origins.length > 0
          destinations += "|"
        end
        destinations += location.latitude.to_s + "," + location.longitude.to_s
      }

      # logger.debug(matrix_locations.to_s)

      url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" + origins + "&destinations=" + destinations + "&key=" + ENV['GOOGLE_MAP_KEY']
      # Rails.logger.debug(url)

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      # logger.debug(response.body)

      json = JSON.parse(response.body)
      m_index = 0 # matrix_index
      sub_locations.each_index {|index|
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
              else
                LocationTravel.create(location_from_id: matrix_location[0], location_to_id: matrix_location[1], distance: meter, duration: minute)
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

end
