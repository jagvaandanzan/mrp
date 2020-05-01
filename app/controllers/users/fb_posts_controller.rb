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
end
