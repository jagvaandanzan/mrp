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
    @operator_id = params[:operator_id]

    @fb_comment_archives = FbCommentArchive.search(params[:archive_id], params[:cid], @fb_post_id, @post_id, @user_name, @message, @start, @finish, @verb, @operator_id).page(params[:page])
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
      operator.comment_minute = FbCommentArchive.by_response_time(oper.id, @start, @finish)
      operator.comment_count = FbCommentArchive.by_response_count(oper.id, @start, @finish)
      operator.no_replied = FbCommentArchive.by_no_replied_count(oper.id, @start, @finish)
      operator.verb_count = FbCommentArchive.by_verb_count(oper.id, @start, @finish)*100/operator.comment_count
      operator.like_count = FbCommentArchive.by_like_count(oper.id, @start, @finish)
      operator.remove_count = FbCommentArchive.by_remove_count(oper.id, @start, @finish)
      operator.hide_count = FbCommentArchive.by_hide_count(oper.id, @start, @finish)
      operator.user_hide_count = FbCommentArchive.by_user_hide_count(oper.id, @start, @finish)
      operator.user_remove_count = FbCommentArchive.by_user_remove_count(oper.id, @start, @finish)
      operator.comment_avg = (operator.comment_minute.to_f / operator.comment_count).to_f.round(1)
      @operators << operator
      @operator_count.push({label: operator.name, value: operator.comment_count})
      @operator_avg.push({y: operator.name, a: operator.comment_avg})
    end

  end

  private

  def set_fb_comment_archive
    @fb_comment_archive = FbCommentArchive.find(params[:id])
  end

end
