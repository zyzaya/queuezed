class QuestionHistory < ApplicationRecord
  include SoftDestroyable

  belongs_to :question
end
