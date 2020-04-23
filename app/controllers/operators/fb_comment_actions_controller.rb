class Operators::FbCommentActionsController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_fb_comment_action, only: [:edit, :show, :update, :destroy]

  def index
    @is_active = params[:is_active].presence || true
    @action_type = params[:action_type]
    @condition = params[:condition]
    @comment = params[:comment]
    @fb_comment_actions = FbCommentAction.search(@is_active, @action_type, @condition, @comment).page(params[:page])
    cookies[:fb_comment_action_page_number] = params[:page]
  end


  def new
    @fb_comment_action = FbCommentAction.new
  end

  def create
    @fb_comment_action = FbCommentAction.new(fb_comment_action_params)

    if @fb_comment_action.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @fb_comment_action.attributes = fb_comment_action_params
    if @fb_comment_action.save
      flash[:success] = t('alert.info_updated')
      redirect_to :action => 'show', id: @fb_comment_action.id
    else
      render 'edit'
    end
  end

  def destroy
    @fb_comment_action.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_fb_comment_action
    @fb_comment_action = FbCommentAction.find(params[:id])
  end

  def fb_comment_action_params
    params.require(:fb_comment_action).permit(:is_active, :action_type, :condition, :comment, :reply_txt)
  end
end
