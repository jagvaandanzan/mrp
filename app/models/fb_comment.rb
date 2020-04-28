class FbComment < ApplicationRecord
  belongs_to :fb_post

  before_destroy :to_archive
  validates :reply_text, presence: true, on: :update

  validates_uniqueness_of :comment_id

  attr_accessor :reply_text, :reply_comment, :verb

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
  scope :order_date, -> {
    order(:date)
  }

  scope :search, ->(fb_post_id, post_id, user_name, message, date) {
    items = order_date
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
    items = items.where(post_id: post_id) if post_id.present?
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }

  def history
    FbCommentArchive.by_parent_id(comment_id).count
  end

  private

  def check_phone
    if message.present?
      # [8-9]{1}[0-9]{7}
      # [89]\d{7}
      phone = message.match(/[8-9]{1}[0-9]{7}/)
      unless phone.nil?
        ProductSaleCall.create(code: fb_post.product_code,
                               quantity: 1,
                               phone: phone)
      end
    end
  end

  def to_archive
    FbCommentArchive.create(fb_post: fb_post,
                            message: message,
                            verb: verb,
                            comment_id: comment_id,
                            parent_id: parent_id,
                            user_id: user_id,
                            user_name: user_name,
                            date: created_at)
  end
end
