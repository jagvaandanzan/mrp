class Users::FbCommentsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment, only: [:show, :update, :destroy, :hide]

  def index
    @fb_post_id = params[:fb_post_id]
    @post_id = params[:post_id]
    @user_name = params[:user_name]
    @message = params[:message]
    @date = params[:date]
    @fb_comments = FbComment.search(@fb_post_id, @post_id, @user_name, @message, @date).page(params[:page])
    cookies[:fb_comment_page_number] = params[:page]
    #check remove
    FbCommentRemove.all.each do |cr|
      fb_comment = FbComment.find_by_comment_id(cr.comment_id)
      if cr.is_edit?
        fb_comment.update_attribute(:message, cr.message)
      else
        fb_comment.verb = cr.verb
        fb_comment.destroy!
      end
      cr.destroy!
    end
    render 'operators/fb_comments/index'
  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_comment.fb_post)
    @comments = ApplicationController.helpers.fb_get_post_comments(@fb_comment.parent_id)
    render 'operators/fb_comments/show'
  end

  def update
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      if @fb_comment.action_type == "reply"
        alert, msg = ApplicationController.helpers.fb_reply_comment(@fb_comment.comment_id, @fb_comment.parent_id, @fb_comment.user_id, @fb_comment.reply_text)
      else
        alert, msg = ApplicationController.helpers.fb_send_message(@fb_comment.comment_id, @fb_comment.reply_text)
      end
      flash[alert] = msg
      redirect_to action: :index
    else
      render 'show'
    end
  end

  def hide
    alert, msg = ApplicationController.helpers.fb_hide_comment(@fb_comment.comment_id)
    flash[alert] = msg
    redirect_to action: :index
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
    params.require(:fb_comment).permit(:action_type, :reply_text)
  end
end
