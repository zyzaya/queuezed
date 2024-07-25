class Question < ApplicationRecord
  include SoftDestroyable

  belongs_to :quiz
  has_and_belongs_to_many :tags
  has_many :answers, -> { Answer.active }, dependent: :destroy
  has_many :histories, dependent: :destroy, class_name: 'QuestionHistory'
  has_many :question_relations, -> { QuestionRelation.active }
  has_many :relations, through: :question_relations, class_name: 'Question'
end
