class FbCommentQuestion < ApplicationRecord
  belongs_to :fb_comment_answer
  belongs_to :operator, optional: true
  belongs_to :user, optional: true

  validates :comment, presence: true
end
