class Users::FbCommentsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment, only: [:show, :edit, :update]

  def index
    @user_name = params[:user_name]
    @message = params[:message]
    @date = if params[:date]
              params[:date].to_time
            else
              Time.now
            end
    @fb_comments = FbComment.search(@user_name, @message, @date).page(params[:page])
    cookies[:fb_comment_page_number] = params[:page]
  end

  def show
  end

  def edit
  end

  def update
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      flash[:success] = t('alert.send_successfully')
      Rails.logger.info("#{@fb_comment.post_id}_#{@fb_comment.comment_id}==>" + @fb_comment.reply_text)
      # @fb_comment.destroy!
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  private

  def set_fb_comment
    @fb_comment = FbComment.find(params[:id])
  end


  def fb_comment_params
    params.require(:fb_comment).permit(:reply_text)
  end
end
