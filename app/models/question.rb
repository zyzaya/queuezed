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
end
