class AnswerHistory < ApplicationRecord
  include SoftDestroyable

  belongs_to :answer
  belongs_to :practice_session
end
