# rspec spec/features/fb_comments_check_spec.rb
require 'rails_helper'
describe "fb_comments", type: :feature do
  it "check reply ..." do

    fb_posts = FbPost.all
    fb_posts.each(&method(:check_post_comments))
  end
end

def check_post_comments(fb_post)
  comment_users = fb_post.fb_comments.by_is_hide(false).by_replied(false).by_user_id(ENV['FB_PAGE_ID'], '!=')
  if comment_users.count > 0
    comment_owns = fb_post.fb_comments.by_is_hide(false).by_replied(false).by_user_id(ENV['FB_PAGE_ID'], '=')
    comments = comment_users.map {|c| [c.comment_id, c]}.to_h

    comment_owns.each do |market|
      # маркет коммент эцэг нь хэрэглэгчийн коммент id бол шууд хариу нь болно
      comment = comments[market.parent_id]
      if comment.present? && !comment.replied
        apply_above_comments(comment_users, comment.parent_id, comment.user_id, comment.date)
        comment.update_attribute(:replied, true)
        puts "parent match ========> " + comment.id.to_s
        # коммент хариултын араас бичсэн асуултад хариулсан бол
      else
        tags = get_message_tags(market.comment_id)
        if tags.size > 0
          puts "tags ========> " + tags[0].to_s
          apply_above_comments(comment_users, market.parent_id, tags[0], market.date)
        end
      end

      puts "market ========> " + market.id.to_s
      market.update_attribute(:replied, true)
    end
  end

end

def apply_above_comments(comment_users, parent_id, user_id, date)
  comment_users.each do |comment|
    if !comment.replied && comment.parent_id == parent_id && comment.user_id == user_id && comment.date < date
      puts "apply_above_comments ========> " + comment.id.to_s
      comment.update_attribute(:replied, true)
    end
  end
end

def get_message_tags(comment_id)
  puts "get_message_tags==>#{comment_id}"
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


def check_post_comments1(fb_post)
  comments = fb_post.fb_comments.by_replied(false).by_user_id(ENV['FB_PAGE_ID'], '!=')
  if comments.count > 0
    comment_owns = fb_post.fb_comments.by_replied(false).by_user_id(ENV['FB_PAGE_ID'], '=').map {|c| [c.parent_id.to_s + "_" + c.sub_mgs, c]}.to_h

    comments.each do |comment|
      if comment.parent_id == "#{ENV['FB_PAGE_ID']}_#{fb_post.post_id}"
        subs = select_start_hash(comment_owns, comment.comment_id + "_")
        if subs.length > 0
          comment.update_attribute(:replied, true)
        end

      else
        subs = select_start_hash(comment_owns, comment.comment_id + "_" + comment.user_name)
        if subs.length > 0
          comment.update_attribute(:replied, true)
        end
        each {|k, v|
          v.update_attribute(:replied, true)
        }
      end
    end
  end

end

def select_start_hash(hash, key_str)
  hash.select {|key, value| key.start_with? key_str}
end