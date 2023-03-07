class AnswerHistory < ApplicationRecord
  belongs_to :answer
  belongs_to :practice_session
end
