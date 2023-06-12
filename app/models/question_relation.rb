class QuestionRelation < ApplicationRecord
  include SoftDestroyable

  belongs_to :question
  belongs_to :relation, class_name: 'Question'
end