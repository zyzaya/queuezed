class PracticeSession < ApplicationRecord
  has_many :questions, through: :practice_questions
  has_many :answer_histories
  belongs_to :quiz
end
