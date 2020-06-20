class Operators::FbCommentArchivesController < Operators::BaseController
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

  end

  def show
    ApplicationController.helpers.set_fb_content(@fb_comment_archive.fb_post)
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
    if params[:operator_id].present?
      operator = Operator.find(params[:operator_id])
      operator.comment_minute = FbCommentArchive.by_response_time(params[:operator_id], @start, @finish)
      operator.comment_count = FbCommentArchive.by_response_count(params[:operator_id], @start, @finish)
      operator.comment_avg = (operator.comment_minute.to_f / operator.comment_count).to_f.round(1)
      @operators << operator
      @operator_count.push({label: operator.name, value: operator.comment_count})
      @operator_avg.push({y: operator.name, a: operator.comment_avg})
    else
      @select_operators.each do |oper|
        operator = Operator.find(oper.id)
        operator.comment_minute = FbCommentArchive.by_response_time(oper.id, @start, @finish)
        operator.comment_count = FbCommentArchive.by_response_count(oper.id, @start, @finish)
        operator.comment_avg = (operator.comment_minute.to_f / operator.comment_count).to_f.round(1)
        @operators << operator
        @operator_count.push({label: operator.name, value: operator.comment_count})
        @operator_avg.push({y: operator.name, a: operator.comment_avg})
      end
    end
    render 'users/fb_comment_archives/report'
  end

  private

  def set_fb_comment_archive
    @fb_comment_archive = FbCommentArchive.find(params[:id])
  end

end
