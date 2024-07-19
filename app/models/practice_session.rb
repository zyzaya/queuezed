class PracticeSession < ApplicationRecord
  has_many :answer_histories
  belongs_to :quiz

  after_initialize :init

  def init
    self.tag_filter = "" if self.tag_filter.nil?
    self.text_filter = "" if self.text_filter.nil?
  end

  def questions
    return Question.where(id: order.flatten.uniq)
  end
end
