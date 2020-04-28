class FbCommentArchive < ApplicationRecord
  acts_as_paranoid

  belongs_to :fb_post
  belongs_to :comment_action, :class_name => "FbCommentAction", optional: true
  belongs_to :archive, :class_name => "FbCommentArchive", optional: true
  has_many :replies, :class_name => "FbCommentArchive", :foreign_key => "archive_id", dependent: :destroy

  validates_uniqueness_of :comment_id

  before_create :find_parent
  after_create :send_auto_reply
  enum verb: {is_add: 0, is_hide: 1, is_remove: 2, is_reaction: 3}

  scope :order_date, -> {
    order(date: :desc)
  }

  scope :by_fb_post, ->(fb_post) {
    where(fb_post_id: fb_post)
  }

  scope :by_parent_id, ->(parent_id) {
    where(parent_id: parent_id)
  }

  scope :is_archive, ->(is = "") {
    where("archive_id IS#{is} ?", nil)
  }

  scope :search, ->(archive_id, comment_id, fb_post_id, post_id, user_name, message, date, verb) {
    items = order_date
    if archive_id.present?
      items = items.where(archive_id: archive_id) if archive_id.present?
    else
      items = items.is_archive
    end
    items = items.where(verb: verb) if verb.present?
    items = items.where(parent_id: comment_id) if comment_id.present?
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
    items = items.where(post_id: post_id) if post_id.present?
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }

  private

  def find_parent
    unless parent_id.start_with? ENV['FB_PAGE_ID']
      fb_comment = FbCommentArchive.find_by_comment_id(parent_id)
      if fb_comment.present?
        self.archive = fb_comment
      end
    end
  end

  # 155, 269
  def send_auto_reply
    if comment_action.present?
      reply_txt = if comment_action.condition == "price"
                    comment_action.reply_txt.gsub("{price}", fb_post.price)
                  elsif comment_action.condition == "feature"
                    comment_action.reply_txt.gsub("{feature}", fb_post.feature)
                  else
                    comment_action.reply_txt
                  end
      action_type = comment_action.action_type

      if action_type == "reply"
        Rails.logger.info("action_auto reply: #{comment_id}==>#{reply_txt}")
        ApplicationController.helpers.fb_reply_comment(comment_id, parent_id, user_id, reply_txt)
      elsif action_type == "message"

        Rails.logger.info("action_auto message: #{comment_id}==>#{reply_txt}")
        ApplicationController.helpers.fb_send_message(comment_id, reply_txt)
      else
        #is_delete

        Rails.logger.info("action_auto hide: #{comment_id}")
        ApplicationController.helpers.fb_hide_comment(comment_id)
      end

      if comment_action.condition == "phone"
        ProductSaleCall.create(code: fb_post.product_code,
                               quantity: 1,
                               message: message,
                               phone: message.match(/[789]\d{7}/))
      end

    end
  end

end
