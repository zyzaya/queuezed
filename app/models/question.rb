class Question < ApplicationRecord
  include SoftDestroyable

  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers, -> { Answer.active }, dependent: :destroy
  has_many :question_histories, dependent: :destroy
  has_many :question_relations, -> { QuestionRelation.active }
  has_many :relations, through: :question_relations, class_name: 'Question'
  has_one :quiz, through: :srs_box
end
