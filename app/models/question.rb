class Question < ApplicationRecord
  include SoftDestroyable
  after_initialize :init

  belongs_to :quiz, counter_cache: true
  has_and_belongs_to_many :tags
  has_many :answers, -> { Answer.active }, dependent: :destroy
  has_many :histories, dependent: :destroy, class_name: 'QuestionHistory'
  has_many :question_relations, -> { QuestionRelation.active }
  has_many :relations, through: :question_relations, class_name: 'Question'

  accepts_nested_attributes_for :answers, allow_destroy: true
  accepts_nested_attributes_for :tags, allow_destroy: true
  accepts_nested_attributes_for :relations, allow_destroy: true

  def tags_attributes=(attributes)
    attributes.each do |a|
      tag = Tag.find_by(id: a["id"])
      self.tags << tag unless tag.nil? || self.tags.include?(tag)
    end
    super(attributes)
  end

  def relations_attributes=(attributes)
    attributes.each do |a|
      relation = Question.find_by(id: a["id"])
      self.relations << relation unless relation.nil? || self.relations.include?(relation)
    end
    super(attributes)
  end

  def submit_answer(practice_session, given)
    history = self.histories.new(practice_session_id: practice_session.id)
    answers = self.answers
    correct_answers = []
    answers.each do |a|
      variants = a.variants
      given_answer = given.find { |g| variants.any?(g) }
      unless given_answer.nil?
        given.delete(given_answer)
        correct_answers << a
        history.answer_histories.new(
          answer_id: a.id,
          expected: a.content,
          given: given_answer,
          correct: true
        )
      end
    end
    incorrect_answers = answers - correct_answers
    correct = incorrect_answers.length == 0
    incorrect_answers.each.with_index do |a, i|
      g = given[i].nil? ? "" : given[i]
      history.answer_histories.new(
        answer_id: a.id,
        expected: a.content,
        given: g,
        correct: false
      )
    end
    update_statistics(correct)
    self.save
  end  

  private
  def init
    update_review

    if self.next_review.nil?
      self.next_review = DateTime.now 
      self.review = true
    end
  end

  def update_review
    if (!self.review && !self.next_review.nil? && self.next_review < DateTime.now)
      self.review = true
    end
  end

  def update_statistics(correct)
    self.times_taken += 1
    self.last_taken = Time.now
    if (correct)
      self.times_correct += 1
      self.current_streak += 1
      if (self.current_streak > self.longest_streak)
        self.longest_streak = self.current_streak
      end
    else
      self.current_streak = 0
    end
  end
end
