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
        prev_after = after
        after = json['paging']['cursors']['after']

      else
        after = prev_after
      end
    end

    render 'admin_users/bank_logins/statement'

  end

  def get_posts(after = nil)
    ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}/posts?access_token=#{ENV['FB_TOKEN']}&fields=id,message#{after.nil? ? '' : '&after=' + after}", 'get', nil)
  end

  def parse_post(data)
    data.each do |json|
      product_name = nil
      product_code = nil
      if json['message'].present?
        json['message'].lines.each_with_index {|line, index|
          if index == 0
            product_name = line.squish
          elsif line.start_with? "#Код:"
            product_code = line.gsub('#Код:', '').gsub(' ', '').squish
            break
          end
        }
        if !product_name.nil? && !product_code.nil?
          FbPost.create(post_id: json['id'].gsub("#{ENV['FB_PAGE_ID']}_", ''), product_name: product_name, product_code: product_code)
        end
      end
    end
  end

end
