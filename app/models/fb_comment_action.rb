class FbCommentAction < ApplicationRecord

  enum action_type: {reply: 0, message: 1, is_delete: 2}
  enum condition: {match: 0, start: 1, contain: 2}

  validates :comment, presence: true, length: {maximum: 255}
  validates :action_type, :condition, presence: true

  validates_uniqueness_of :comment

  validates :reply_txt, presence: true, length: {maximum: 255}, unless: Proc.new {self.is_delete?}

  scope :by_is_active, ->(is_active) {
    where(is_active: is_active)
  }

  scope :order_comment, -> {
    order(:comment)
  }

  scope :search, ->(is_active, action_type, condition, comment) {
    items = order_comment
    items = items.where(is_active: is_active) if is_active.present?
    items = items.where(action_type: action_type) if action_type.present?
    items = items.where(condition: condition) if condition.present?
    items = items.where('comment LIKE :value', value: "%#{comment}%") if comment.present?
    items
  }

  def active_stat
    ("<i class='fa fa" + (is_active ? "-check text-success" : "-times text-danger") + "' style='font-size: 16px;'></i>&nbsp;&nbsp;").html_safe
  end

end
