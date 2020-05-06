module FacebookHelper

  def fb_reply_comment(comment_id, parent_id, user_id, message)
    unless parent_id.start_with? ENV['FB_PAGE_ID']
      message = "@[#{user_id}] #{message}"
    end
    param = {
        "message": message
    }

    response = api_send("#{ENV['FB_API']}#{comment_id}/comments?access_token=#{ENV['FB_TOKEN']}", 'post', param.to_json)

    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end

  def fb_send_message(comment_id, message)
    param = {
        "messaging_type": "RESPONSE",
        "recipient": {
            "comment_id": "#{comment_id}"
        },
        "message": {
            "text": message
        }
    }
    response = api_send("#{ENV['FB_API']}me/messages?access_token=#{ENV['FB_TOKEN']}", 'post', param.to_json)
    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end

  def fb_send_file(comment_id, url)
    param = {
        recipient: {
            comment_id: "#{comment_id}"
        },
        message: {
            attachment: {
                type: "image",
                payload: {
                    url: url,
                    is_reusable: true
                }
            }
        }
    }
    Rails.logger.info(param.to_json)
    response = api_send("#{ENV['FB_API']}me/messages?access_token=#{ENV['FB_TOKEN']}", 'post', param.to_json)
    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end

  def fb_delete_comment(comment_id)
    response = api_send("#{ENV['FB_API']}#{comment_id}?access_token=#{ENV['FB_TOKEN']}", 'delete', nil)
    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end

  def fb_hide_comment(comment_id)
    response = api_send("#{ENV['FB_API']}#{comment_id}?access_token=#{ENV['FB_TOKEN']}", 'post', {"is_hidden": true}.to_json)
    if response.code.to_i == 200
      [:success, t('alert.hide_successfully')]
    else
      [:alert, response.body.to_s]
    end
  end

  def fb_like_comment(comment_id)
    response = api_send("#{ENV['FB_API']}#{comment_id}/likes?access_token=#{ENV['FB_TOKEN']}", 'post', nil)
    if response.code.to_i == 200
      [:success, t('alert.like_successfully')]
    else
      [:alert, response.body.to_s]
    end
  end

  def fb_get_post_message(post_id)
    api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{post_id}?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
  end

  def fb_get_post_comments(parent_id)
    if parent_id.start_with? ENV['FB_PAGE_ID']
      []
    else
      FbCommentArchive.by_parent_id(parent_id).order_date
    end
  end

  def set_fb_content(fb_post)
    unless fb_post.content.present?
      response = fb_get_post_message(fb_post.post_id)
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        fb_post.update_attribute(:content, json['message'])
      end
    end
  end
end