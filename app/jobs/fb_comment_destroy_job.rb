class FbCommentDestroyJob < ApplicationJob
  queue_as :default

  def perform(comment)
    ActionCable.server.broadcast 'fb_comment_channel', destroy: comment.id
  end
end
