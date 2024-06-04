class PracticeSession < ApplicationRecord
  has_many :answer_histories
  belongs_to :quiz

  def questions
    return Question.where(id: order.flatten.uniq)
  end
end
