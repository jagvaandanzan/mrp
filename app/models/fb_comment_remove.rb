class FbCommentRemove < ApplicationRecord
  enum verb: {is_add: 0, is_hide: 1, is_remove: 2, is_reaction: 3, is_edited: 4, user_hide: 6, user_remove: 7}
end
