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
  enum verb: {is_add: 0, is_hide: 1, is_remove: 2, is_reaction: 3, is_send_image: 4, is_send_text: 5, user_hide: 6, user_remove: 7, to_archive: 8, auto_phone: 9}

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

  scope :search, ->(archive_id, comment_id, fb_post_id, post_id, user_name, message, start, finish, s_hour, e_hour, verb, operator_id) {
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
    items = items.where('? <= HOUR(date) AND HOUR(date) <= ?', s_hour.to_i, e_hour.to_i) unless (s_hour.to_i == 0 && e_hour.to_i == 23)
    items = items.where(operator_id: operator_id) if operator_id.present?
    items
  }

  scope :operator_by_response, ->(start, finish) {
    items = select('operators.id', 'operators.name')
                .joins(:operator)
                .group('operators.id')
    items = items.where('? <= fb_comment_archives.date AND fb_comment_archives.date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  scope :by_response, ->(operator_id, start, finish) {
    items = where("verb = ?", 0)
                .or(where("user_id IS NOT ?", nil))
                .or(where("verb IS ?", nil))
                .or(where("verb = ?", 4))
                .or(where("verb = ?", 5))
    items = items.joins(:operator)
                .where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  scope :by_response_time, ->(operator_id, start, finish) {
    items = by_response(operator_id, start, finish)
    items.sum("TIMESTAMPDIFF(MINUTE,fb_comment_archives.date,fb_comment_archives.created_at)")
  }

  scope :by_response_count, ->(operator_id, start, finish) {
    items = by_response(operator_id, start, finish)
    items.count
  }

  scope :by_count, ->(start, finish) {
    items = where("verb = ?", 0)
                .or(where("verb IS ?", nil))
                .or(where("user_id IS NOT ?", nil))
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days)
    items.count
  }

  scope :by_no_replied_count, ->(operator_id, start, finish) {
    items = joins("LEFT JOIN fb_comment_archives as replies ON fb_comment_archives.id = replies.archive_id")
    items = items.where("replies.id IS ?", nil)
    items = items.where("fb_comment_archives.user_id IS NOT ?", nil)
    items = items.where('? <= fb_comment_archives.date AND fb_comment_archives.date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.count
  }

  scope :by_verb_count, ->(operator_id, start, finish, verb) {
    items = where("verb = ?", verb)
    items = items.joins(:operator)
                .where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.count
  }
  scope :mpr_phone, ->(operator_id, start, finish) {
    items = joins(:fb_post)
    items = items.where("fb_posts.product_code != ?", '000000')
    items = items.where("verb = ?", 9)
    items = items.joins(:operator)
                .where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.count
  }

  scope :by_user_count, ->(operator_id, start, finish) {
    items = joins(:operator)
    items = items.where(operator_id: operator_id) if operator_id.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.pluck(:user_id).uniq.count
  }

  scope :to_chat_count, ->(operator_id, start, finish) {
    items = where("verb = ?", 4)
                .or(where("verb = ?", 5))
    items = items.joins(:operator)
                .where(operator_id: operator_id) if operator_id.present?
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
                               status_id: 1,
                               message: message,
                               phone: phone.to_i,
                               source: "sr_comment")
      end

    end
  end

end
