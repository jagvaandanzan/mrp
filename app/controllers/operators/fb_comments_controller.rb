class Operators::FbCommentsController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment, only: [:show, :update, :destroy, :hide, :like]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = 'Хасагдсан байна!'
    redirect_to action: :index
  end

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
      if fb_comment.present?
        if cr.is_edited?
          fb_comment.update_attribute(:message, cr.message)
        else
          # Хэрэглэгч устгасан бол 5 нэмж user_ рүү оруулна
          fb_comment.verb = (fb_comment.is_visible ? cr.verb.gsub('is', 'user') : cr.verb)
          fb_comment.destroy!
        end
      end
      cr.destroy!
    end
  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_comment.fb_post)
    @comments = ApplicationController.helpers.fb_get_post_comments(@fb_comment.parent_id)
  end

  def update
    @fb_comment.attributes = fb_comment_params
    if @fb_comment.valid?
      if @fb_comment.action_type == "reply"
        if @fb_comment.comment_answer_id.present?
          fb_comment_answer = FbCommentAnswer.find(@fb_comment.comment_answer_id)
          fb_comment_answer.update_attribute(:used, fb_comment_answer.used + 1)
        else
          answer = @fb_comment.reply_text
          answer = answer.gsub('Оройн мэнд. ', '')
                       .gsub('Оройн мэнд, ', '')
                       .gsub('Өдрийн мэнд. ', '')
                       .gsub('Өдрийн мэнд, ', '')
                       .gsub('Өглөөний мэнд. ', '')
                       .gsub('Өглөөний мэнд, ', '')
          answers = FbCommentAnswer.by_answer(answer)
          if answers.present?
            fb_comment_answer = answers.first
            Rails.logger.info("greeting_answer: #{fb_comment_answer.id} => #{answer}")
          else
            fb_comment_answer = FbCommentAnswer.create(answer: @fb_comment.reply_text, operator: current_operator)
          end
        end
        FbCommentQuestion.create(operator: current_operator,
                                 fb_comment_answer: fb_comment_answer,
                                 comment: @fb_comment.message,
                                 post_id: @fb_comment.fb_post.post_id,
                                 is_selected: @fb_comment.comment_answer_id.present?,
                                 fb_user_id: @fb_comment.user_id)

        alert, msg = ApplicationController.helpers.fb_reply_comment(@fb_comment.comment_id, @fb_comment.parent_id, @fb_comment.user_id, fb_comment_answer.answer)
        if alert == :success
          check_post_comments(@fb_comment.fb_post, @fb_comment, Time.current)
        end
      elsif @fb_comment.action_type == "reply_image"
        upload = Upload.create(image: @fb_comment.reply_image)
        alert, msg = ApplicationController.helpers.fb_reply_comment_img(@fb_comment.comment_id, upload.image.url)
        if alert == :success
          check_post_comments(@fb_comment.fb_post, @fb_comment, Time.current)
        end
      elsif @fb_comment.action_type == "image"
        upload = Upload.create(image: @fb_comment.reply_image)
        alert_i, msg = ApplicationController.helpers.fb_send_file(@fb_comment.comment_id, upload.image.url)
        Rails.logger.info("fb_send_file: #{alert_i} => #{msg}")
        alert, msg_2 = ApplicationController.helpers.fb_reply_comment(@fb_comment.comment_id, @fb_comment.parent_id, @fb_comment.user_id, @fb_comment.reply_image_text)
        if alert_i == :success && alert == :success
          @fb_comment.verb = "is_send_image"
          @fb_comment.operator_id = current_operator.id
          @fb_comment.destroy!
        end
      else
        alert, msg = ApplicationController.helpers.fb_send_message(@fb_comment.comment_id, @fb_comment.reply_message)
        if alert == :success
          @fb_comment.verb = "is_send_text"
          @fb_comment.operator_id = current_operator.id
          @fb_comment.destroy!
        end
      end
      flash[alert] = msg
      redirect_to action: :index
    else
      @comments = ApplicationController.helpers.fb_get_post_comments(@fb_comment.parent_id)
      render 'show'
    end
  end

  def like
    alert, msg = ApplicationController.helpers.fb_like_comment(@fb_comment.comment_id)
    flash[alert] = msg
    @fb_comment.verb = "is_reaction"
    @fb_comment.operator_id = current_operator.id
    @fb_comment.destroy!
    redirect_to action: :index
  end

  def hide
    alert, msg = ApplicationController.helpers.fb_hide_comment(@fb_comment.comment_id)
    flash[alert] = msg
    @fb_comment.update_attributes(is_visible: false, operator_id: current_operator.id)
    redirect_to action: :index
  end

  def destroy
    @fb_comment.operator_id = current_operator.id
    @fb_comment.verb = "to_archive"
    @fb_comment.destroy!
    flash[:success] = t('alert.to_archive')
    redirect_to action: :index
  end

  private

  def set_fb_comment
    @fb_comment = FbComment.find(params[:id])
  end


  def fb_comment_params
    params.require(:fb_comment).permit(:action_type, :reply_text, :reply_image, :reply_image_text, :reply_message, :comment_answer_id)
  end

  def check_post_comments(fb_post, fb_comment, date)
    msg = ""
    comment_users = fb_post.fb_comments
    if comment_users.count > 0

      # маркет коммент эцэг нь хэрэглэгчийн коммент id бол шууд хариу нь болно
      if fb_comment.parent_id.start_with? ENV['FB_PAGE_ID']
        msg = apply_above_comments(comment_users, fb_comment.parent_id, fb_comment.user_id, fb_comment.date)
        # puts "parent match ========> " + fb_comment.id.to_s
        fb_comment.operator_id = current_operator.id
        fb_comment.destroy!
        # коммент хариултын араас бичсэн асуултад хариулсан бол
      else
        msg = apply_above_comments(comment_users, fb_comment.parent_id, fb_comment.user_id, date)
      end
    end

    msg
  end

  def apply_above_comments(comment_users, parent_id, user_id, date)
    msg = ""
    comment_users.each do |comment|
      if comment.parent_id == parent_id && comment.user_id == user_id && comment.date < date
        # puts "apply_above_comments ========> " + comment.id.to_s
        msg = msg + comment.message + ", " if comment.message.present?
        comment.operator_id = current_operator.id
        comment.destroy!
      end
    end
    msg
  end
end
