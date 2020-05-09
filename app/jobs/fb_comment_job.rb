class FbCommentJob < ApplicationJob
  queue_as :default

  def perform(comment)
    ActionCable.server.broadcast 'fb_comment_channel', comment: render(comment)
  end

  private

  def render(comment)
    renderer = ApplicationController.renderer.new(
        http_host: ENV['HTTP_HOST'],
        https: ENV['HTTPS']
    )
    renderer.render(partial: 'operators/fb_comments/row_index', locals: {fb_comment: comment})
  end
end
