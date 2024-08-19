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
    return [] if finished?
    
    current_ids = self.order[self.current].filter { |e| !e.nil? }
    return Question.includes(:answers).where(id: current_ids)
  end

  def next_question
    current = (self.current + 1).clamp(1..self.length + 1)
    self.update(current: current)
  end

  def finished?
    self.current >= self.length
  end
end
