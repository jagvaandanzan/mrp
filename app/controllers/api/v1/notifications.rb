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
                  fb_post = FbPost.by_post_id(post_id)

                  if fb_post.present?

                    FbComment.create(fb_post: fb_post.first,
                                     channel: 0,
                                     message: obj[:message],
                                     comment_id: obj[:comment_id],
                                     parent_id: obj[:parent_id],
                                     user_id: from_id,
                                     user_name: from_id != ENV['FB_PAGE_ID'] ? obj[:from][:name] : nil,
                                     date: Time.at(obj[:created_time]))
                  end
                else
                  fb_comments = FbComment.by_comment_id(obj[:comment_id])
                  if fb_comments.present?
                    fb_comment = fb_comments.first
                    if obj[:verb] == "hide"
                      fb_comment.update(is_hide: true)
                    elsif obj[:verb] == "edited"
                      fb_comment.update(message: obj[:message])
                    end
                  end
                end

                # fb_comments = FbComment.by_post_id(parent_ids[0])
                #                   .by_comment_id(parent_ids[1])
                # if fb_comments.present?
                #   fb_comments.destroy_all
                # else
                #   fb_comment_replies = FbComment.by_post_id(parent_ids[0])
                #                            .by_parent_id(parent_ids[1])
                #   msg = obj[:message]
                #   fb_comment_replies.each {|com|
                #     if msg.present? && msg.start_with?(com.user_name)
                #       com.destroy!
                #     end
                #   }

                # # Rails.logger.info(entry)
                # Rails.logger.info("post_id=" + obj[:post_id])
                # Rails.logger.info("comment_id=" + obj[:comment_id])
                # Rails.logger.info("parent_id=" + obj[:parent_id])

              end

            }
          }

          status 200
        end
      end
    end
  end
end