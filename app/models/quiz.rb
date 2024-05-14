class Quiz < ApplicationRecord
  belongs_to :user
  has_many :srs_boxes
  has_many :questions, -> { Question.active }, through: :srs_boxes
  has_many :tags, through: :questions
  has_many :practice_sessions
end
