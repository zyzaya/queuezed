class PracticeSession < ApplicationRecord
  has_many :answer_histories
  belongs_to :quiz

  after_initialize :init

  def init
    self.tagFilter = "" if self.tagFilter.nil?
    self.textFilter = "" if self.textFilter.nil?
  end

  def questions
    return Question.where(id: order.flatten.uniq)
  end
end
