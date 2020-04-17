module FacebookHelper

  def fb_reply_comment(comment_id, message)
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
    response = api_send("#{ENV['FB_API']}#{comment_id}/comments?access_token=#{ENV['FB_TOKEN']}", 'delete', nil)
    if response.code.to_i == 200
      [:success, t('alert.send_successfully')]
    else
      json = JSON.parse(response.body)
      [:alert, json.to_s]
    end
  end
end