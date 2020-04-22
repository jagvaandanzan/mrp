class AdminUsers::FacebooksController < AdminUsers::BaseController

  def posts
    after = nil
    prev_after = ""

    response = get_posts(after)
    if response.code.to_i == 200
      @code = response.code.to_i
      @body = response.body

      json = JSON.parse(response.body)
      parse_post(json['data'])
      after = json['paging']['cursors']['after']
    end

    while after != prev_after
      response = get_posts(after)
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        parse_post(json['data'])
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

  def parse_post(data)
    data.each do |json|
      if json['is_published']
        product_name = nil
        product_code = nil
        if json['message'].present? && json['message'].include?("77779990")
          json['message'].lines.each_with_index {|line, index|
            if index == 0
              product_name = line.squish
            elsif line.start_with? "#Код:"
              product_code = line.gsub('#Код:', '').gsub(' ', '').squish
              break
            end
          }
          unless product_name.nil?
            data = DateTime.parse(json['created_time'])
            FbPost.create(post_id: json['id'].gsub("#{ENV['FB_PAGE_ID']}_", ''), product_name: product_name, product_code: product_code.nil? ? '000000' : product_code, created_at: data, updated_at: data)
          end
        end
      end
    end
  end

end
