class QuestionHistory < ApplicationRecord
  include SoftDestroyable

  has_many :answer_histories, -> { AnswerHistory.active }
  belongs_to :question
end
