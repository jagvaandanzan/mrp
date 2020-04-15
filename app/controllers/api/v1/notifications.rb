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

              # Өөрийн бичсэн үзэгдэлүүдийг алгасах
              Rails.logger.info(entry.to_s)
              if from_id != '0'
                if obj[:item] == "comment"
                  parent_ids = obj[:parent_id].split('_')

                  if from_id != ENV['FB_PAGE_ID']
                    post_comment_ids = obj[:comment_id].split('_')
                    post_id = post_comment_ids[0]

                    fb_post = FbPost.by_post_id(post_id)

                    if fb_post.present?
                      FbComment.create(fb_post: fb_post.first,
                                       message: obj[:message],
                                       post_id: post_id,
                                       comment_id: post_comment_ids[1],
                                       parent_id: parent_ids[1],
                                       user_id: from_id,
                                       user_name: obj[:from][:name],
                                       date: Time.at(obj[:created_time]))
                    end

                  else
                    fb_comments = FbComment.by_post_id(parent_ids[0])
                                      .by_comment_id(parent_ids[1])
                    if fb_comments.present?
                      fb_comments.destroy_all
                    else
                      fb_comment_replies = FbComment.by_post_id(parent_ids[0])
                                               .by_parent_id(parent_ids[1])
                      msg = obj[:message]
                      fb_comment_replies.each {|com|
                        if msg.present? && msg.start_with?(com.user_name)
                          com.destroy!
                        end
                      }
                    end

                    # # Rails.logger.info(entry)
                    # Rails.logger.info("post_id=" + obj[:post_id])
                    # Rails.logger.info("comment_id=" + obj[:comment_id])
                    # Rails.logger.info("parent_id=" + obj[:parent_id])
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