class QuestionRelation < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  belongs_to :question
  belongs_to :relation, class_name: 'Question'
end