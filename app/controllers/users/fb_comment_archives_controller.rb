class Users::FbCommentArchivesController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment_archive, only: [:show]

  def index
    @verb = params[:verb]
    @fb_post_id = params[:fb_post_id]
    @post_id = params[:post_id]
    @user_name = params[:user_name]
    @message = params[:message]
    if params[:start].present?
      @start = params[:start]
      @finish = params[:finish]
    else
      today = Time.now.beginning_of_day
      @start = @finish= today.strftime('%Y/%m/%d')
    end

    @fb_comment_archives = FbCommentArchive.search(params[:archive_id], params[:cid], @fb_post_id, @post_id, @user_name, @message, @start, @finish, @verb).page(params[:page])
    cookies[:fb_comment_archive_page_number] = params[:page]
    render 'operators/fb_comment_archives/index'
  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_comment_archive.fb_post)
    render 'operators/fb_comment_archives/show'
  end

  private

  def set_fb_comment_archive
    @fb_comment_archive = FbCommentArchive.find(params[:id])
  end

end
