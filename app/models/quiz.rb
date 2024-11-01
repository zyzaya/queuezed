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

  def new_practice(text_filter: "", tag_filter: [], review: false, difficult: false, limit: false)
    order = create_order(
      text_filter: text_filter, 
      tag_filter: tag_filter, 
      review: review,
      difficult: difficult,
      limit: limit
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
  def create_order(text_filter: "", tag_filter: "", review: false, difficult: false, limit: false)
    questions = filter_review_and_difficult(review, difficult, limit)
    text_filter = text_filter.downcase
    ids = []
    order = []
    ## shuffle questions, 
    questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |q|
      if (matches_filters(q, ids, text_filter, tag_filter))
        # group related questions
        related_ids = q.relations.filter do |r|
          matches_filters(r, ids, text_filter, tag_filter)
        end
        related_ids = related_ids.map { |r| r.id }
        q_ids = [q.id] + related_ids
        order << q_ids
        ids += q_ids
      end
    end

    return order
  end

  def matches_filters(question, existing, text_filter, tag_filter)
    !existing.include?(question.id) &&
      has_answers(question) &&
      has_text(question, text_filter) &&
      has_tags(question, tag_filter)
  end

  def filter_review_and_difficult(review, difficult, limit)
    # if review && difficult
    #   return self.questions.where(review: true, difficult: true)
    # elsif review && !difficult
    #   return self.questions.where(review: true)
    # elsif difficult && !review
    #   return self.questions.where(difficult: true)
    # else
    #   return self.questions
    # end
    ret = self.questions
    ret = ret.where(review: true) if review
    ret = ret.where(difficult: true) if difficult
    ret = ret.limit(limit) if limit != false
    return ret
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
