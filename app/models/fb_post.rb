class FbPost < ApplicationRecord
  acts_as_paranoid
  belongs_to :fb_post, :class_name => "FbPost", optional: true
  has_many :fb_posts, :foreign_key => "fb_post_id", dependent: :destroy

  enum status: {unstrained: 0, downloaded: 1, is_ignore: 2}
  validates :post_id, :product_name, :product_code, :price, presence: true, length: {maximum: 255}
  validates_uniqueness_of :post_id
  validates :content, presence: true
  after_create :get_post_attachment
  before_save :check_downloaded
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
    if fb_post.present?
      "#{fb_post.product_name}, #{fb_post.product_code}"
    else
      "#{product_name}, #{product_code}"
    end
  end

  private

  def check_downloaded
    if unstrained?
      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{post_id}?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        message = json['message']
        if message.present? && message.include?("77779990")
          str1_marker_string = "#Бүтээгдэхүүний_тухай"
          str2_marker_string = "#"
          price = nil
          feature = nil
          product_name = nil
          product_code = nil
          message.lines.each_with_index {|line, index|
            if index == 0
              product_name = line.squish
            elsif line.start_with? "#Үнэ"
              p_m = message[/#Үнэ(.*?)#Код/m, 1]
              if p_m.present?
                price = p_m.squish
              else
                price = line.squish.gsub("#Үнэ", '')
              end
              price = start_det(price) if price.present?
            elsif line.start_with? "#Код:"
              product_code = line.scan(/\d+/).first
              # product_code = line.gsub('#Код:', '').gsub(' ', '').squish
              break
            end
          }
          unless product_name.nil?
            if message.include?("#Бүтээгдэхүүний_тухай")
              feature = message[/#{str1_marker_string}(.*?)#{str2_marker_string}/m, 1]
              if feature.nil?
                i = message.index("#{str1_marker_string}")
                message = message[i..message.length]
                j = message.index("#{str2_marker_string}")
                j = message.length if j == 0

                feature = message[21, j]
              end
              feature = start_det(feature)
              feature = remove_empty_line(feature)
            end
            data = DateTime.parse(json['created_time'])

            self.product_name = product_name.length > 255 ? product_name[0.254] : product_name

            self.product_code = product_code.nil? ? '000000' : product_code
            self.price = if price.present?
                           price.length > 255 ? price[0.254] : price
                         else
                           nil
                         end
            self.feature = feature
            self.content = message
            self.created_at = data
          end
        else
          self.status = 2
        end
      end
    end
  end

  def remove_empty_line(str)
    txt = ""
    str.lines.each do |s|
      if s.length > 2
        txt += s
      end
    end
    if txt.length > 0
      txt[0..txt.length - 2]
    else
      txt
    end
  end

  def start_det(str)
    if str.length > 3
      str = str[0..3].gsub(':', '').gsub('.', '').gsub(' ', '') + str[4..str.length]
    end
    str
  end

  def get_post_attachment
    unless fb_post.present?
      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}_#{self.post_id}/attachments?access_token=#{ENV['FB_TOKEN']}", 'get', nil)
      if response.code.to_i == 200
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
