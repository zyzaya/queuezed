class PracticeSession < ApplicationRecord
  has_many :practice_questions
  has_many :questions, through: :practice_questions
  belongs_to :quiz
end
