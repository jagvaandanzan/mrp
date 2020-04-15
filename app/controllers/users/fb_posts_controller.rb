class Users::FbPostsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_post, only: [:show, :edit, :update, :destroy]

  def index
    @product_name = params[:product_name]
    @product_code = params[:product_code]
    @fb_posts = FbPost.search(@product_name, @product_code).page(params[:page])
    cookies[:fb_post_page_number] = params[:page]

    # ali_categories = AliCategory.select(:link).group(:link).having("count(*) > 1")
    # Rails.logger.info(ali_categories.count)
    # ali_categories.each do |ali_category|
    #
    #   categories = AliCategory.by_link(ali_category.link)
    #   len = categories.count
    #   cc = 1
    #   categories.reverse.each_with_index do |category, index|
    #     Rails.logger.info("#{category.id} #{category.name} #{category.link}")
    #     if !category.prod && cc < len
    #       category.destroy!
    #       cc += 1
    #     end
    #   end
    # end
  end

  def new
    @fb_post = FbPost.new
  end

  def create
    @fb_post = FbPost.new(fb_post_params)

    if @fb_post.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
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
    params.require(:fb_post).permit(:post_id, :product_name, :product_code)
  end
end
