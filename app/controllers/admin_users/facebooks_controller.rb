class AdminUsers::FacebooksController < AdminUsers::BaseController

  def to_archives
    count = 0
    @code = 200

    AliCategory.all.each do |ali_cat|

    end

    # FbComment.all.each do |fb_comment|
    #   fb_comment.destroy!
    #   count = count + 1
    # end
    #
    # @body = "to_archives: #{count}"
    # render 'admin_users/bank_logins/statement'
  end

  def attachments
    count = 0
    FbPost.fb_post_is_null.each do |fb_post|
      Rails.logger.info("fb_post.post_id = #{fb_post.post_id}")
      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{fb_post.post_id}/attachments?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
      if response.code.to_i == 200
        @code = response.code.to_i
        json = JSON.parse(response.body)
        data = json['data'][0]
        if data.present?
          sub_attachments = data['subattachments']
          if sub_attachments.present?
            attach = sub_attachments['data']
            if attach.length > 1
              attach.each do |js|
                new_fb_post = FbPost.create(fb_post: fb_post,
                                            post_id: js['target']['id'],
                                            content: js['media']['image']['src'],
                                            created_at: fb_post.created_at,
                                            updated_at: fb_post.updated_at)
                new_fb_post.save(validate: false)
              end
              count = count + 1
            end
          end
        end
      end
    end
    @body = "posts: #{count}"
    render 'admin_users/bank_logins/statement'
  end

  def posts
    hash_posts = FbPost.all.map {|p| [p.post_id, p]}.to_h

    count = 0

    end_date = DateTime.new(2020, 6, 1)
    until_date = DateTime.new(2018, 8, 1).to_i
    while until_date <= end_date.to_i
      after = nil
      prev_after = ""
      start_date = end_date - 1.month
      Rails.logger.info("#{start_date} => #{end_date}")
      response = get_posts(after, "&since=#{start_date.to_i}&until=#{end_date.to_i}")
      if response.code.to_i == 200
        @code = response.code.to_i

        json = JSON.parse(response.body)
        count = parse_post(json['data'], hash_posts)
        after = json['paging']['cursors']['after']
      end

      while after != prev_after
        response = get_posts(after, "&since=#{start_date.to_i}&until=#{end_date.to_i}")
        if response.code.to_i == 200
          json = JSON.parse(response.body)
          count = count + parse_post(json['data'], hash_posts)
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
      end_date = start_date
    end

    @body = "posts: #{count}"
    render 'admin_users/bank_logins/statement'

  end

  def get_posts(after = nil, date)
    Rails.logger.info("date=#{date}")
    unless after.nil?
      logger.info("after=#{after}")
    end
    ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}/published_posts?access_token=#{ENV['FB_TOKEN']}&fields=id,message,created_time#{date}#{after.nil? ? '' : '&after=' + after}", 'get', nil)
  end

  def parse_post(data, hash_posts)
    count = 0
    str1_marker_string = "#Бүтээгдэхүүний_тухай"
    str2_marker_string = "#"
    data.each do |json|
      post_id = json['id'].gsub("#{ENV['FB_PAGE_ID']}_", '')
      logger.info("post_id: #{post_id}")
      message = json['message']
      price = nil
      feature = nil
      hash_post = hash_posts[post_id]
      if hash_post.present?
        logger.info("post_id: bn")
        # if message.present? && message.include?("77779990")
        #   message.lines.each {|line|
        #     if line.start_with? "#Үнэ"
        #       price = line.squish.gsub("#Үнэ", '')
        #       price = start_det(price)
        #       break
        #     end
        #   }
        #   if message.include?("#Бүтээгдэхүүний_тухай")
        #     feature = message[/#{str1_marker_string}(.*?)#{str2_marker_string}/m, 1]
        #     if feature.nil?
        #       i = message.index("#{str1_marker_string}")
        #       message = message[i..message.length]
        #       j = message.index("#{str2_marker_string}")
        #       j = message.length if j == 0
        #       feature = message[21, j]
        #     end
        #     feature = start_det(feature)
        #     feature = remove_empty_line(feature)
        #   end
        #   hash_post.price = price
        #   hash_post.feature = feature
        #   hash_post.save(validate: false)
        #   count = count + 1
        # end

      else # Шинээр үүсгэнэ
        product_name = nil
        product_code = nil
        if message.present? && message.include?("77779990")
          message.lines.each_with_index {|line, index|
            if index == 0
              product_name = line.squish
            elsif line.start_with? "#Үнэ"
              p_m = message[/#Үнэ(.*?)#Код/m, 1]
              if p_m.present?
                price = p_m.squish
              else
                price = line.squish.gsub("#Үнэ", '')
              end
              price = start_det(price) if price.present?
            elsif line.start_with? "#Код:"
              product_code = line.scan(/\d+/).first
              # product_code = line.gsub('#Код:', '').gsub(' ', '').squish
              break
            end
          }
          unless product_name.nil?
            if message.include?("#Бүтээгдэхүүний_тухай")
              feature = message[/#{str1_marker_string}(.*?)#{str2_marker_string}/m, 1]
              if feature.nil?
                i = message.index("#{str1_marker_string}")
                message = message[i..message.length]
                j = message.index("#{str2_marker_string}")
                j = message.length if j == 0

                feature = message[21, j]
              end
              feature = start_det(feature)
              feature = remove_empty_line(feature)
            end
            data = DateTime.parse(json['created_time'])
            fb_post = FbPost.new(post_id: post_id,
                                 product_name: product_name.length > 255 ? product_name[0.254] : product_name,
                                 product_code: product_code.nil? ? '000000' : product_code,
                                 price: if price.present?
                                          price.length > 255 ? price[0.254] : price
                                        else
                                          nil
                                        end,
                                 feature: feature,
                                 content: message,
                                 created_at: data,
                                 updated_at: data)
            fb_post.save(validate: false)
            count = count + 1
          end
        end
      end

    end
    count
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

  def start_det(str)
    if str.length > 3
      str = str[0..3].gsub(':', '').gsub('.', '').gsub(' ', '') + str[4..str.length]
    end
    str
  end
end
