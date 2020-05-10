class FbComment < ApplicationRecord
  belongs_to :fb_post

  before_destroy :to_archive
  after_create_commit {FbCommentJob.perform_later self}
  after_destroy_commit do
    ActionCable.server.broadcast 'fb_comment_channel', destroy: self.id
  end

  validates_uniqueness_of :comment_id

  with_options :if => Proc.new {|m| !m.comment_answer_id.present? && !m.reply_image.present?} do
    validates :reply_text, presence: true, on: :update
  end

  with_options :if => Proc.new {|m| !m.comment_answer_id.present? && !m.reply_text.present?} do
    validates :reply_image, presence: true, on: :update
  end

  attr_accessor :action_type, :reply_text, :reply_image, :comment_answer_id, :verb

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
  scope :is_visible, -> {
    where(is_visible: true)
  }

  scope :search, ->(fb_post_id, post_id, user_name, message, date) {
    items = order_date
                .is_visible
    items = items.where(fb_post_id: fb_post_id) if fb_post_id.present?
    items = items.joins(:fb_post)
                .where("fb_posts.post_id = ?", post_id) if post_id.present?
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }

  def history
    FbCommentArchive.by_parent_id(comment_id).count
  end

  # def self.render_with_signed_in_user(*args)
  #   ActionController::Renderer::RACK_KEY_TRANSLATION['warden'] ||= 'warden'
  #   proxy = if self.oper
  #       Warden::Proxy.new({}, Warden::Manager.new({})).tap{|i| i.set_user(user, scope: :user) }
  #   renderer = self.renderer.new('warden' => proxy)
  #   renderer.render(*args)
  # end

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
                            photo: photo,
                            verb: verb,
                            comment_id: comment_id,
                            parent_id: parent_id,
                            user_id: user_id,
                            user_name: user_name,
                            date: created_at)
  end
end
