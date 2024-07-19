class AnswerHistory < ApplicationRecord
  include SoftDestroyable

  belongs_to :question_history
  belongs_to :answer
end
