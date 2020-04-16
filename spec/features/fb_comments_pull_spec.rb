# rspec spec/features/fb_comments_pull_spec.rb
require 'rails_helper'
describe "fb_comments", type: :feature do
  it "pull ..." do

    fb_posts = FbPost.order_checked
    if fb_posts.present?
      fb_post = fb_posts.first
      get_post_comments(fb_post)
    end
  end
end

def sent_request(post_id, summary, after)
  ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{post_id}/comments?access_token=#{ENV['FB_TOKEN']}&#{ENV['FB_COMMENT_ORDER']}#{summary}&#{ENV['FB_COMMENT_FIELDS']}#{after}", 'get', nil)
end

def get_post_comments(fb_post)
  response = sent_request(fb_post.post_id, '&summary=total_count', '')
  # puts response.code.to_s
  # puts response.body.to_s

  if response.code.to_i == 200
    json = JSON.parse(response.body)
    total_count = json['summary']['total_count'].to_i
    comment_count = fb_post.comments

    if fb_post.comments < total_count
      comment_ids = []
      comment_news = Hash.new
      comment_owns = Hash.new
      comment_users = Hash.new
      # Хэрэглэгчидын бичсэн комментууд
      fb_post.fb_comments.by_user_id(ENV['FB_PAGE_ID'], '!=').each do |comment|
        comment_ids << comment.comment_id
        comment_users[comment.comment_id] = comment
      end
      # Market.mn бичсэн комментууд
      fb_post.fb_comments.by_user_id(ENV['FB_PAGE_ID'], '=').each do |comment|
        comment_ids << comment.comment_id
        comment_owns[comment.comment_id] = comment
      end

      comment_count, comment_news, comment_users, comment_owns = get_comments_data(json['data'], comment_ids, comment_count, comment_news, comment_users, comment_owns)

      # Бүх хуудсыг авах хүртэлээ явуулна
      while comment_count < total_count do
        response = sent_request(fb_post.post_id, '', "&after=#{json['paging']['cursors']['next']}")
        if response.code.to_i == 200
          json = JSON.parse(response.body)
          comment_count, comment_news, comment_users, comment_owns = get_comments_data(json['data'], comment_ids, comment_count, comment_news, comment_users, comment_owns)
        else
          comment_count = total_count
        end
      end

      # эцэг коммент болон, хариу бичсэн эсэхийг шалгана
      comment_news.each do |comment|

      end

    end
  end

end

def get_comments_data(data, comment_ids, comment_count, comment_news, comment_users, comment_owns)
  data.each {|d|
    unless comment_ids.include?(d['id'])

      from = d['from']
      parent_id = d['parent'].present? ? d['parent']['id'] : nil
      tag_id = d['message_tags'].present? ? d['message_tags']['id'] : nil
      fb_comment = FbComment.new(message: d['message'],
                                 channel: 1,
                                 comment_id: d['id'],
                                 parent_id: parent_id,
                                 user_id: from.present? ? from['id'] : nil,
                                 user_name: (from.present? && from['id'] != ENV['FB_PAGE_ID']) ? from['name'] : nil,
                                 date: DateTime.parse(d['created_time']),
                                 tags: tag_id)
      comment_news[fb_comment.comment_id] = fb_comment
      if fb_comment.user_id == ENV['FB_PAGE_ID']
        comment_owns[comment.comment_id] = comment
      else
        comment_users[comment.comment_id] = comment
      end
    end
    comment_count += 1
  }
  [comment_count, comment_news, comment_users, comment_owns]
end