class FbComment < ApplicationRecord
  belongs_to :fb_post
  belongs_to :fb_comment, optional: true

  enum channel: {hook: 0, api: 1}

  validates :reply_text, presence: true, on: :update

  validates_uniqueness_of :comment_id

  attr_accessor :reply_text, :reply_comment

  scope :by_fb_post, ->(fb_post) {
    where(fb_post_id: fb_post)
  }

  scope :by_post_id, ->(post_id) {
    where(post_id: post_id)
  }

  scope :by_comment_id, ->(comment_id) {
    where(comment_id: comment_id)
  }
  scope :by_parent_id, ->(parent_id) {
    where(parent_id: parent_id)
  }
  scope :by_user_id, ->(user_id, eq) {
    where("user_id #{eq} ?", user_id)
  }
  scope :by_replied, ->(replied) {
    where(replied: replied)
  }
  scope :by_is_hide, ->(is_hide) {
    where(is_hide: is_hide)
  }
  scope :order_date, -> {
    order(:date)
  }

  scope :search, ->(fb_post_id, user_name, message, date) {
    items = order_date
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }

  def sub_mgs
    l = message.length > 30 ? 30 : message.length
    message[0..l]
  end
end
