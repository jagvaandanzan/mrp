class Users::FbPostsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_post, only: [:show, :edit, :update, :destroy]

  def index
    @post_id = params[:post_id]
    @product_name = params[:product_name]
    @product_code = params[:product_code]
    @fb_posts = FbPost.search(@post_id, @product_name, @product_code).page(params[:page])
    cookies[:fb_post_page_number] = params[:page]
  end

  def new
    time = Time.current
    @hour_start = time.hour
    @hour_end = (time + 1.hour).hour
    @date = time
  end

  def download
    date = params[:date].to_time

    hash_posts = FbPost.all.map {|p| [p.post_id, p]}.to_h

    count = 0

    since_date = date.change(hour: params[:hour_start].to_i)
    until_date = date.change(hour: params[:hour_end].to_i)
    after = nil
    prev_after = ""
    Rails.logger.info("#{since_date} => #{until_date}")
    response = get_posts(after, "&since=#{since_date.to_i}&until=#{until_date.to_i}")
    if response.code.to_i == 200
      @code = response.code.to_i

      json = JSON.parse(response.body)
      count = parse_post(json['data'], hash_posts)
      after = json['paging']['cursors']['after']
    end

    while after != prev_after
      response = get_posts(after, "&since=#{since_date.to_i}&until=#{until_date.to_i}")
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        count = count + parse_post(json['data'], hash_posts)
        if json['paging'].present? && json['paging']['cursors'].present?
          prev_after = after
          after = json['paging']['cursors']['after']
        else
          after = prev_after
        end

      else
        after = prev_after
      end
    end


    flash[:success] = t('alert.downloaded_successfully', count: count)
    redirect_to action: :index
  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_post)
  end

  def edit
  end

  def update
    @fb_post.attributes = fb_post_params
    if @fb_post.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @fb_post.id
    else
      render 'edit'
    end
  end

  def destroy
    @fb_post.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_fb_post
    @fb_post = FbPost.find(params[:id])
  end

  def fb_post_params
    params.require(:fb_post).permit(:post_id, :product_name, :product_code, :content, :price, :feature)
  end

  def get_posts(after = nil, date)
    Rails.logger.info("date=#{date}")
    unless after.nil?
      logger.info("after=#{after}")
    end
    ApplicationController.helpers.api_send("#{ENV['FB_API']}#{ENV['FB_PAGE_ID']}/published_posts?access_token=#{ENV['FB_TOKEN']}&fields=id,message,created_time#{date}#{after.nil? ? '' : '&after=' + after}", 'get', nil)
  end

  def parse_post(data, hash_posts)
    count = 0
    str1_marker_string = "#Бүтээгдэхүүний_тухай"
    str2_marker_string = "#"
    data.each do |json|
      post_id = json['id'].gsub("#{ENV['FB_PAGE_ID']}_", '')
      logger.info("post_id: #{post_id}")
      message = json['message']
      price = nil
      feature = nil
      hash_post = hash_posts[post_id]
      unless hash_post.present?
        product_name = nil
        product_code = nil
        if message.present? && message.include?("77779990")
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
            fb_post = FbPost.new(post_id: post_id,
                                 product_name: product_name.length > 255 ? product_name[0.254] : product_name,
                                 product_code: product_code.nil? ? '000000' : product_code,
                                 price: if price.present?
                                          price.length > 255 ? price[0.254] : price
                                        else
                                          nil
                                        end,
                                 feature: feature,
                                 content: message,
                                 created_at: data,
                                 updated_at: data)
            fb_post.save(validate: false)
            count = count + 1
          end
        end
      end

    end
    count
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
end
