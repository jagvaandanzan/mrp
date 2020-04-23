class Operators::FbCommentArchivesController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment_archive, only: [:show]

  def index
    @fb_post_id = params[:fb_post_id]
    @user_name = params[:user_name]
    @message = params[:message]
    @date = if params[:date].present?
              params[:date].to_time
            else
              Time.now.beginning_of_day
            end
    @fb_comment_archives = FbCommentArchive.search(params[:archive_id], params[:cid], @fb_post_id, @user_name, @message, @date).page(params[:page])
    cookies[:fb_comment_archive_page_number] = params[:page]

  end

  def show
    response = ApplicationController.helpers.fb_get_post_message(@fb_comment_archive.fb_post.post_id)
    @post_message = if response.code.to_i == 200
                      json = JSON.parse(response.body)
                      json['message']
                    else
                      ""
                    end
  end

  private

  def set_fb_comment_archive
    @fb_comment_archive = FbCommentArchive.find(params[:id])
  end

end
