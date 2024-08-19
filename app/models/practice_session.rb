class PracticeSession < ApplicationRecord
  has_many :question_histories
  belongs_to :quiz

  after_initialize :init

  def init
    self.tag_filter = "" if self.tag_filter.nil?
    self.text_filter = "" if self.text_filter.nil?
  end

  def questions
    return Question.where(id: order.flatten.uniq)
  end

  def current_questions
    current_ids = self.order[self.current].filter { |e| !e.nil? }
    return Question.includes(:answers).where(id: current_ids)
  end
end
