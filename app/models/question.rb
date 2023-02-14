class Question < ApplicationRecord
  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers
  has_many :question_histories
  has_many :question_relations
  has_many :relations, through: :question_relations, class_name: 'Question'
end
