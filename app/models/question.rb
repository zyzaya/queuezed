class Question < ApplicationRecord
  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers
  has_many :question_histories
end
