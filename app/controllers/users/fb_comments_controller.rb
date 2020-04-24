class Users::FbCommentsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment, only: [:show, :edit, :update, :messages, :send_message]

  def index
    @fb_post_id = params[:fb_post_id]
    @user_name = params[:user_name]
    @message = params[:message]
    @date = if params[:date].present?
              params[:date].to_time
            else
              Time.now.beginning_of_day
            end
    @fb_comments = FbComment.search(@fb_post_id, @user_name, @message, @date).page(params[:page])
    cookies[:fb_comment_page_number] = params[:page]

    render 'operators/fb_comments/index'
  end

  def show
    render 'operators/fb_comments/show'
  end

  def edit
    @post_message, @comments = ApplicationController.helpers.fb_get_post(@fb_comment.fb_post.post_id, @fb_comment.parent_id)
    render 'operators/fb_comments/edit'
  end

  def update
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      alert, msg = ApplicationController.helpers.fb_reply_comment(@fb_comment.comment_id, @fb_comment.parent_id, @fb_comment.user_id, @fb_comment.reply_text)

      flash[alert] = msg

      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def messages
    @post_message, @comments = ApplicationController.helpers.fb_get_post(@fb_comment.fb_post.post_id, @fb_comment.parent_id)
    render 'operators/fb_comments/messages'
  end

  def send_message
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?

      alert, msg = ApplicationController.helpers.fb_send_message(@fb_comment.comment_id, @fb_comment.reply_text)

      flash[alert] = msg

      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @fb_comment.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_fb_comment
    @fb_comment = FbComment.find(params[:id])
  end


  def fb_comment_params
    params.require(:fb_comment).permit(:reply_text)
  end
end
