class Question < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers, -> { where Answer.active }, dependent: :destroy
  has_many :question_histories, dependent: :destroy
  has_many :question_relations, -> { where QuestionRelation.active }
  has_many :relations, through: :question_relations, class_name: 'Question'

  before_destroy :destroy_relations
  private
  def destroy_relations
    QuestionRelation.where(question_id: self.id).or(QuestionRelation.where(relation_id: self.id)).destroy_all
  end
end
