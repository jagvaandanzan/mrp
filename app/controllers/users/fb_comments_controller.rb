class Users::FbCommentsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment, only: [:show, :edit, :update]

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
  end

  def show
  end

  def edit
  end

  def update
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      # response = ApplicationController.helpers.api_send("#{ENV['FB_API']}639996292999968_1118810478451878/comments?filter=stream&order=reverse_chronological&summary=total_count&access_token=#{ENV['FB_TOKEN']}", 'get')

      param = {
          "message": @fb_comment.reply_comment
      }

      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}#{@fb_comment.post_id}_#{@fb_comment.comment_id}/comments?access_token=#{ENV['FB_TOKEN']}", 'post', param.to_json)

      Rails.logger.info(response.code.to_i)

      if response.code.to_i == 200
        flash[:success] = t('alert.send_successfully')
      else
        json = JSON.parse(response.body)
        # flash[:alert] = json[:json]
        flash[:alert] = json.to_s
      end

      # @fb_comment.destroy!
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def messages
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      param = {
          "messaging_type": "RESPONSE",
          "recipient": {
              "comment_id": "#{@fb_comment.post_id}_#{@fb_comment.comment_id}"
          },
          "message": {
              "text": @fb_comment.reply_text
          }
      }
      response = ApplicationController.helpers.api_send("#{ENV['FB_API']}me/messages?access_token=#{ENV['FB_TOKEN']}", 'post', param.to_json)

      Rails.logger.info(response.code.to_i)

      if response.code.to_i == 200
        flash[:success] = t('alert.send_successfully')
      else
        json = JSON.parse(response.body)
        # flash[:alert] = json[:json]
        flash[:alert] = json.to_s
      end

      # @fb_comment.destroy!
      redirect_to action: :index
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

  def set_fb_comment
    @fb_comment = FbComment.find(params[:id])
  end


  def fb_comment_params
    params.require(:fb_comment).permit(:reply_text)
  end
end
