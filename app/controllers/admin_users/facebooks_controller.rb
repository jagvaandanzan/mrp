class AdminUsers::FacebooksController < AdminUsers::BaseController

  def posts
    hash_posts = FbPost.all.map {|p| [p.post_id, p]}.to_h

    after = nil
    prev_after = ""

    response = get_posts(after)
    if response.code.to_i == 200
      @code = response.code.to_i
      @body = response.body

      json = JSON.parse(response.body)
      parse_post(json['data'], hash_posts)
      after = json['paging']['cursors']['after']
    end

    while after != prev_after
      response = get_posts(after)
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        parse_post(json['data'], hash_posts)
        if json['paging'].present? && json['paging']['cursors'].present?
          prev_after = after
          after = json['paging']['cursors']['after']
        else
          after = prev_after
        end

      else
        after = prev_after
      end
    end

    render 'admin_users/bank_logins/statement'

  end

  def get_posts(after = nil)
    unless after.nil?
      logger.info("after=#{after}")
    end
    ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}/posts?access_token=#{ENV['FB_TOKEN']}&fields=id,message,created_time,is_published#{after.nil? ? '' : '&after=' + after}", 'get', nil)
  end

  def parse_post(data, hash_posts)

    str1_marker_string = "#Бүтээгдэхүүний_тухай"
    str2_marker_string = "#"
    data.each do |json|
      if json['is_published']
        post_id = json['id'].gsub("#{ENV['FB_PAGE_ID']}_", '')
        logger.info("post_id: #{post_id}")
        message = json['message']
        price = nil
        feature = nil
        hash_post = hash_posts[post_id]
        if hash_post.present?
          if message.present? && message.include?("77779990")
            message.lines.each {|line|
              if line.start_with? "#Үнэ"
                price = (line.gsub(/[^0-9]/, '')).to_i
                break
              end
            }
            if message.include?("#Бүтээгдэхүүний_тухай")
              feature = message[/#{str1_marker_string}(.*?)#{str2_marker_string}/m, 1]
              if feature.start_with? " :"
                feature[0] = ''
              elsif feature.start_with? " :"
                feature[0] = ''
                feature[1] = ''
              end
              unless feature.nil?
                feature = remove_empty_line(feature)
              end
            end
            hash_post.price = price
            hash_post.feature = feature
            hash_post.save(validate: false)
          end

        else # Шинээр үүсгэнэ
          product_name = nil
          product_code = nil
          if message.present? && message.include?("77779990")
            message.lines.each_with_index {|line, index|
              if index == 0
                product_name = line.squish
              elsif line.start_with? "#Үнэ"
                price = (line.gsub(/[^0-9]/, '')).to_i
              elsif line.start_with? "#Код:"
                product_code = line.gsub('#Код:', '').gsub(' ', '').squish
                break
              end
            }
            unless product_name.nil?
              if message.include?("#Бүтээгдэхүүний_тухай")
                feature = message[/#{str1_marker_string}(.*?)#{str2_marker_string}/m, 1]
                if feature.start_with? " :"
                  feature[0] = ''
                elsif feature.start_with? " :"
                  feature[0] = ''
                  feature[1] = ''
                end
                unless feature.nil?
                  feature = remove_empty_line(feature)
                end
              end
              data = DateTime.parse(json['created_time'])
              fb_post = FbPost.new(post_id: post_id, product_name: product_name, product_code: product_code.nil? ? '000000' : product_code, price: price, feature: feature, created_at: data, updated_at: data)
              fb_post.save(validate: false)
            end
          end
        end

      end
    end
  end

  def remove_empty_line(str)
    txt = ""
    str.lines.each do |s|
      if s.length > 2
        txt += s
      end
    end
    if txt.length > 0
      txt[0..txt.length - 2]
    else
      txt
    end
  end
end
