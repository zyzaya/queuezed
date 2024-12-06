class QuestionHistory < ApplicationRecord
  include SoftDestroyable

  has_many :answer_histories, -> { AnswerHistory.active }, dependent: :destroy
  belongs_to :question
end
