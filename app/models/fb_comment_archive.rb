class FbCommentArchive < ApplicationRecord
  acts_as_paranoid

  belongs_to :fb_post
  belongs_to :archive, :class_name => "FbCommentArchive", optional: true
  has_many :replies, :class_name => "FbCommentArchive", :foreign_key => "archive_id", dependent: :destroy

  before_create :find_parent

  scope :order_date, -> {
    order(:date)
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

  scope :search, ->(archive_id, comment_id, fb_post_id, user_name, message, date) {
    items = order_date
    if archive_id.present?
      items = items.where(archive_id: archive_id) if archive_id.present?
    else
      items = items.is_archive
    end
    items = items.where(parent_id: comment_id) if comment_id.present?
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
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
end
