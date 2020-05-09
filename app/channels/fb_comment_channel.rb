class FbCommentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "fb_comment_channel"
    # get_user.appear(true)
  end

  def unsubscribed
    # get_user.appear(false)
  end

  private

  def get_user
    # current_operator.present? current_operator: current_user
  end
end
