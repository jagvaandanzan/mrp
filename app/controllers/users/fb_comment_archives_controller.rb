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
      @start = @finish = today.strftime('%Y/%m/%d')
    end
    if params[:start_hour].present?
      @start_hour = params[:start_hour]
      @end_hour = params[:end_hour]
    else
      @start_hour = 0
      @end_hour = 23
    end
    @operator_id = params[:operator_id]

    @fb_comment_archives = FbCommentArchive.search(params[:archive_id], params[:cid], @fb_post_id, @post_id, @user_name, @message,
                                                   @start, @finish, @start_hour, @end_hour, @verb, @operator_id).page(params[:page])
    cookies[:fb_comment_archive_page_number] = params[:page]
    render 'operators/fb_comment_archives/index'
  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_comment_archive.fb_post)
    render 'operators/fb_comment_archives/show'
  end

  def report
    @operator_id = params[:operator_id]
    if params[:start].present?
      @start = params[:start]
      @finish = params[:finish]
    else
      today = Time.now.beginning_of_day
      @start = @finish = today.strftime('%Y/%m/%d')
    end
    @operators = []
    @operator_count = []
    @operator_avg = []
    @select_operators = FbCommentArchive.operator_by_response(@start, @finish)
    @select_operators.each do |oper|
      operator = Operator.find(oper.id)
      operator.user_count = FbCommentArchive.by_user_count(oper.id, @start, @finish)
      operator.to_chat_count = FbCommentArchive.to_chat_count(oper.id, @start, @finish)
      operator.comment_minute = FbCommentArchive.by_response_time(oper.id, @start, @finish)
      operator.comment_count = FbCommentArchive.by_response_count(oper.id, @start, @finish)
      operator.no_replied = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 8)
      operator.reply_percent = operator.no_replied > 0 ? ((((operator.no_replied * 100) / operator.comment_count).to_f).round(1)) : 0
      operator.like_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 3)
      operator.remove_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 2)
      operator.hide_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 1)
      operator.user_hide_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 6)
      operator.user_remove_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish, 7)
      operator.comment_avg = (operator.comment_minute > 0 && operator.comment_count > 0) ? ((operator.comment_minute.to_f / operator.comment_count).to_f).round(1) : 0
      operator.mpr_phone = FbCommentArchive.mpr_phone(oper.id, @start, @finish)
      @operators << operator
      @operator_count.push({label: operator.name, value: operator.comment_count})
      @operator_avg.push({y: operator.name, a: operator.comment_avg})
    end

    @total_count = FbCommentArchive.by_count(@start, @finish)

  end

  private

  def set_fb_comment_archive
    @fb_comment_archive = FbCommentArchive.find(params[:id])
  end

end
