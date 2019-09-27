class Users::CalcController < ApplicationController
  require "net/https"
  require "uri"

  def vrptw22
    # save_travels(Location.order('RAND()').first(12))
  end

  def vrptw
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

    system "cd " + folder_path + " && python salesman.py " + file_temp

    result_path = folder_path + "#{file_temp}_result.txt"
    until File.exists?(result_path)
      sleep(2)
    end

    @route_result = File.read(result_path)
  end

  def save_travels(locations)
    # print ''
    # STDOUT.flush

    hash_locations = locations.map {|i| [i.id, i]}.to_h
    length = hash_locations.length #locations.map(&:id).to_a
    # өмнө нь авсан зайнуудыг авна
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
