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

  def fb_delete_comment(comment_id)
    response = api_send("#{ENV['FB_API']}#{comment_id}?access_token=#{ENV['FB_TOKEN']}", 'delete', nil)
    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end

  def fb_get_post_message(post_id)
    api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{post_id}?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
  end

  def fb_get_post(post_id, parent_id)
    response = fb_get_post_message(post_id)
    if response.code.to_i == 200
      json = JSON.parse(response.body)
      comments =
          if parent_id.start_with? ENV['FB_PAGE_ID']
            []
          else
            FbCommentArchive.by_parent_id(parent_id).order_date
          end

      [json['message'], comments]
    else
      ["", []]
    end
  end
end