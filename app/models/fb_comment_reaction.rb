class FbCommentReaction < ApplicationRecord
  belongs_to :fb_post, optional: true

  enum reaction: {comment: 0, like: 1, love: 2, wow: 3, care: 4, support: 5}
end
