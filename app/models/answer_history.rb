class AnswerHistory < ApplicationRecord
  include SoftDestroyable

  belongs_to :practice_session
  belongs_to :question_history
  belongs_to :answer
end
