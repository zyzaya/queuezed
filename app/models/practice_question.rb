class PracticeQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :practice_session
end
