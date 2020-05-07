class FbPost < ApplicationRecord
  acts_as_paranoid
  belongs_to :fb_post, :class_name => "FbPost", optional: true
  has_many :fb_posts, :foreign_key => "fb_post_id", dependent: :destroy
  validates :post_id, :product_name, :product_code, :price, presence: true, length: {maximum: 255}
  validates_uniqueness_of :post_id
  validates :content, presence: true
  after_create :get_post_attachment

  has_many :fb_comments, dependent: :destroy

  scope :order_date, -> {
    order(created_at: :desc)
  }
  scope :order_code, -> {
    order(:product_code)
  }

  scope :order_updated, -> {
    order(updated: :desc)
  }

  scope :by_post_id, ->(post_id) {
    where(post_id: post_id)
  }

  scope :fb_post_is_null, -> {
    where("fb_post_id IS ?", nil)
  }

  scope :search, ->(post_id, name, code) {
    items = fb_post_is_null
                .order_date
    items = items.where(post_id: post_id) if post_id.present?
    items = items.where('product_name LIKE :value', value: "%#{name}%") if name.present?
    items = items.where('product_code LIKE :value', value: "%#{code}%") if code.present?
    items
  }

  def full_name
    "#{product_name}, #{product_code}"
  end

  private

  def get_post_attachment
    unless fb_post.present?
      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{self.post_id}/attachments?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
      if response.code.to_i == 200
        @code = response.code.to_i
        json = JSON.parse(response.body)
        data = json['data'][0]
        if data.present?
          sub_attachments = data['subattachments']
          if sub_attachments.present?
            attach = sub_attachments['data']
            if attach.length > 1
              attach.each do |js|
                new_fb_post = FbPost.new(fb_post: self,
                                         post_id: js['target']['id'],
                                         product_name: self.product_name,
                                         product_code: self.product_code,
                                         price: self.price,
                                         feature: self.feature,
                                         content: js['media']['image']['src'],
                                         created_at: self.created_at,
                                         updated_at: self.updated_at)
                new_fb_post.save(validate: false)
              end
            end
          end
        end
      end
    end
  end
end
