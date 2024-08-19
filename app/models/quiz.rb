class Quiz < ApplicationRecord
  MAX_RANK = 5
  belongs_to :user
  has_many :questions, -> { Question.active }, dependent: :destroy
  has_many :tags, through: :questions
  has_many :practice_sessions, dependent: :destroy

  after_initialize :init

  accepts_nested_attributes_for :questions, allow_destroy: true

  def init
    self.rank_1_interval = 1.days.to_i
    self.rank_2_interval = 3.days.to_i
    self.rank_3_interval = 1.week.to_i
    self.rank_4_interval = 1.month.to_i
    self.rank_5_interval = 4.months.to_i
  end

  def interval_duration(rank)
    duration = nil
    case rank
    when 0
      duration = 0
    when 1
      duration = self.rank_1_interval
    when 2
      duration = self.rank_2_interval
    when 3
      duration = self.rank_3_interval
    when 4
      duration = self.rank_4_interval
    when 5
      duration = self.rank_5_interval
    else
    end
    ActiveSupport::Duration.build(duration) unless duration.nil?
  end

  def new_practice(text_filter: "", tag_filter: [], review: false)
    order = create_order(
      text_filter: text_filter, 
      tag_filter: tag_filter, 
      review: review
    )
    return nil if order.length <= 0

    max = order.max { |a, b| a.length <=> b.length }.length
    order.map { |e| e.fill(nil, e.length, max - e.length) }
    return self.practice_sessions.new(
      current: 0,
      length: order.length,
      order: order,
      text_filter: text_filter,
      tag_filter: tag_filter
    )
  end
  private
  def create_order(text_filter: "", tag_filter: "", review: false)
    questions = filter_review(review)
    text_filter = text_filter.downcase
    ids = []
    order = []
    questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |q|
      if (!ids.include?(q.id) &&
        has_answers(q) &&
        has_text(q, text_filter) &&
        has_tags(q, tag_filter))
        # group related questions
        q_ids = [q.id] + q.relations.pluck(:id)
        order << q_ids
        ids += q_ids
      end
    end
    return order
  end

  def filter_review(review)
    review ? self.questions.where(review: true) : self.questions
  end

  def has_answers(question)
    !question.answers.empty?
  end

  def has_text(question, filter)
    filter.eql?("") || question.content.downcase.include?(filter)
  end

  def has_tags(question, filter)
    (filter - question.tags.pluck(:id)).length == 0
  end
end
