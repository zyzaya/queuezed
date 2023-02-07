class PracticeSession < ApplicationRecord
  has_many :practice_questions, dependent: :destroy
  has_many :questions, through: :practice_questions
  belongs_to :quiz
end
