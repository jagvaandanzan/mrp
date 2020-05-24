class FbCommentArchive < ApplicationRecord
  acts_as_paranoid

  belongs_to :fb_post
  belongs_to :operator, optional: true
  belongs_to :comment_action, :class_name => "FbCommentAction", optional: true
  belongs_to :archive, :class_name => "FbCommentArchive", optional: true
  has_many :replies, :class_name => "FbCommentArchive", :foreign_key => "archive_id", dependent: :destroy

  validates_uniqueness_of :comment_id

  before_create :find_parent
  after_create :send_auto_reply
  enum verb: {is_add: 0, is_hide: 1, is_remove: 2, is_reaction: 3, is_send_image: 4, is_send_text: 5}

  scope :order_date, -> {
    order(:date)
  }

  scope :order_date_desc, -> {
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

  scope :search, ->(archive_id, comment_id, fb_post_id, post_id, user_name, message, start, finish, verb) {
    items = order_date_desc
    if archive_id.present?
      items = items.where(archive_id: archive_id) if archive_id.present?
    else
      items = items.is_archive
    end
    items = items.where(verb: verb) if verb.present?
    items = items.where(parent_id: comment_id) if comment_id.present?
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
    items = items.joins(:fb_post)
                .where("fb_posts.post_id=?", post_id) if post_id.present?
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  scope :operator_by_response, ->(start, finish) {
    items = select('operators.id', 'operators.name')
                .joins(:operator)
                .group('operators.id')
    items = items.where('? <= fb_comment_archives.date AND fb_comment_archives.date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  scope :by_response_time, ->(operator_id, start, finish) {
    items = joins(:operator)
    items = items.where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.sum("TIMESTAMPDIFF(MINUTE,fb_comment_archives.date,fb_comment_archives.created_at)")
  }

  scope :by_response_count, ->(operator_id, start, finish) {
    items = joins(:operator)
    items = items.where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.count
  }

  def operator_name
    if self.operator.present?
      self.operator.name
    else
      ""
    end
  end

  private

  def find_parent
    unless parent_id.start_with? ENV['FB_PAGE_ID']
      fb_comment = FbCommentArchive.find_by_comment_id(parent_id)
      if fb_comment.present?
        self.archive = fb_comment
      else
        fb_comment = FbCommentArchive.by_parent_id(parent_id).is_archive
        self.archive = fb_comment.first if fb_comment.present?
      end
    end
  end

  def send_auto_reply
    if comment_action.present?
      fb_post_real = fb_post.fb_post.present? ? fb_post.fb_post : fb_post
      reply_txt = if comment_action.condition == "price"
                    comment_action.reply_txt.gsub("{price}", fb_post_real.price)
                  elsif comment_action.condition == "feature"
                    comment_action.reply_txt.gsub("{feature}", fb_post_real.feature)
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
        phone = message.match(/[789]\d{7}/).to_s
        ProductSaleCall.create(code: fb_post_real.product_code,
                               quantity: 1,
                               message: message,
                               phone: phone.to_i)
      end

    end
  end

end
