class FbCommentAnswer < ApplicationRecord
  belongs_to :operator, optional: true
  belongs_to :user, optional: true
  has_many :fb_comment_questions

  validates :answer, presence: true

  scope :order_by_name, -> {
    order(:answer)
  }

  scope :by_answer, ->(answer) {
    where('LOWER(answer) = ?', answer.downcase) if answer.present?
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('answer LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

end
