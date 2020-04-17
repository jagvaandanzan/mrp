module API
  module V1
    class Notifications < Grape::API
      resource :notifications do
        desc "POST notifications"
        get do
          if params['hub.mode'].present? && params['hub.challenge'].present? &&
              params['hub.verify_token'].present? && params['hub.verify_token'] == "ea_market_mrp_secret"

            Rails.logger.debug("mode:" + params['hub.mode'].to_s)
            Rails.logger.debug("challenge:" + params['hub.challenge'].to_s)
            Rails.logger.debug("verify_token:" + params['hub.verify_token'].to_s)

            present params['hub.challenge'].to_i

          end
        end

        post do
          params do
            requires :entry, type: Array[JSON]
            requires :object, type: String
          end
          # json = env['api.request.body'].to_json
          # object = params[:object]
          entries = params[:entry]

          entries.each {|entry|
            entry[:changes].each {|change|
              obj = change[:value]
              from_id = obj[:from][:id]

              # Rails.logger.info(entry.to_json)
              # Өөрийн бичсэн үзэгдэлүүдийг алгасах
              if from_id != '0' && obj[:item] == "comment"
                Rails.logger.info(entry.to_json)
                if obj[:verb] == "add"
                  post_id = obj[:post_id].split('_')[1]
                  fb_posts = FbPost.by_post_id(post_id)

                  if fb_posts.present?
                    fb_post = fb_posts.first
                    if from_id == ENV['FB_PAGE_ID']
                      check_post_comments(fb_post, obj[:parent_id], obj[:comment_id], Time.at(obj[:created_time]))
                    else
                      unless check_auto_reply(obj[:message], obj[:comment_id])
                        FbComment.create(fb_post: fb_post,
                                         message: obj[:message],
                                         comment_id: obj[:comment_id],
                                         parent_id: obj[:parent_id],
                                         user_id: from_id,
                                         user_name: obj[:from][:name],
                                         date: Time.at(obj[:created_time]))
                      end

                    end
                  end
                else
                  fb_comments = FbComment.by_comment_id(obj[:comment_id])
                  if fb_comments.present?
                    fb_comment = fb_comments.first
                    if obj[:verb] == "hide" && obj[:verb] == "remove"
                      # fb_comment.update_attribute(:is_hide, true)
                      fb_comment.destroy!
                    elsif obj[:verb] == "edited"
                      fb_comment.update_attribute(message, obj[:message])
                    end
                  end
                end

                # reaction, хэрэглэгчийн коммент дээр дарсан бол хариулсан гэж үзнэ
              elsif obj[:item] == "reaction" && from_id == ENV['FB_PAGE_ID'] && obj[:comment_id].present?
                Rails.logger.info(entry.to_json)
                post_id = obj[:post_id].split('_')[1]
                fb_posts = FbPost.by_post_id(post_id)
                if fb_posts.present?
                  fb_post = fb_posts.first
                  fb_comment = fb_post.fb_comments.by_comment_id(obj[:comment_id])
                  if fb_comment.present?
                    fb_comment.destroy!
                  end
                end
              end

            }
          }

          status 200
        end
      end
    end
  end
end

def check_post_comments(fb_post, parent_id, comment_id, date)
  comment_users = fb_post.fb_comments
  if comment_users.count > 0
    comments = comment_users.map {|c| [c.comment_id, c]}.to_h

    # маркет коммент эцэг нь хэрэглэгчийн коммент id бол шууд хариу нь болно
    comment = comments[parent_id]
    if comment.present?
      apply_above_comments(comment_users, comment.parent_id, comment.user_id, comment.date)
      # puts "parent match ========> " + comment.id.to_s
      comment.destroy!
      # коммент хариултын араас бичсэн асуултад хариулсан бол
    else
      tags = get_message_tags(comment_id)
      if tags.size > 0
        # puts "tags ========> " + tags[0].to_s
        apply_above_comments(comment_users, parent_id, tags[0], date)
      end
    end

  end

end

def apply_above_comments(comment_users, parent_id, user_id, date)
  comment_users.each do |comment|
    if comment.parent_id == parent_id && comment.user_id == user_id && comment.date < date
      # puts "apply_above_comments ========> " + comment.id.to_s
      comment.destroy!
    end
  end
end

def get_message_tags(comment_id)
  # puts "get_message_tags==>#{comment_id}"
  user_ids = []
  response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{comment_id}?fields=message_tags.fields(id)&access_token=#{ENV['FB_TOKEN']}", 'get', nil)
  if response.code.to_i == 200
    json = JSON.parse(response.body)
    if json['message_tags'].present?
      json['message_tags'].each do |tags|
        user_ids << tags['id']
      end
    end
  end

  user_ids
end

def check_auto_reply(message, comment_id)
  fb_comment_actions = FbCommentAction.by_is_active(true)
  fb_comment_actions.each do |ac|
    logger.info("action_auto check " + ac.comment)
    if ac.condition == "contain"
      if message.include? ac.comment
        return action_auto_reply(comment_id, ac)
      end
    elsif ac.condition == "start"
      if message.start_with? ac.comment
        return action_auto_reply(comment_id, ac)
      end
    else
      #match
      if message == ac.comment
        return action_auto_reply(comment_id, ac)
      end
    end
  end

  false
end

def action_auto_reply(comment_id, fb_comment_action)
  if fb_comment_action.action_type == "reply"

    logger.info("action_auto reply: #{comment_id}==>#{fb_comment_action.reply_txt}")
    alert, msg = ApplicationController.helpers.fb_reply_comment(comment_id, fb_comment_action.reply_txt)
    alert == :success
  elsif fb_comment_action.action_type == "message"

    logger.info("action_auto message: #{comment_id}==>#{fb_comment_action.reply_txt}")
    alert, msg = ApplicationController.helpers.fb_send_message(comment_id, fb_comment_action.reply_txt)
    alert == :success
  else
    #is_delete

    logger.info("action_auto delete: #{comment_id}")
    alert, msg = ApplicationController.helpers.fb_delete_comment(comment_id)
    alert == :success
  end

  false
end