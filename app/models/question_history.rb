class QuestionHistory < ApplicationRecord
  include SoftDestroyable

  has_many :answer_histories
  belongs_to :question
end
