class Question < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers, -> { Answer.active }, dependent: :destroy
  has_many :question_histories, dependent: :destroy
  has_many :question_relations, -> { QuestionRelation.active }
  has_many :relations, through: :question_relations, class_name: 'Question'

  before_destroy :destroy_relations
  
  def soft_destroy
    time = Time.now
    update_column(:deleted_at, time)
    answers.each do |a| a.soft_destroy(time) end
    # question_relations.each do |r| r.soft_delete end
  end

  def restore
    time = deleted_at
    update_column(:deleted_at, nil)
    answers.each do |a| a.restore(time) end
  end

  private
  def destroy_relations
    QuestionRelation.where(question_id: self.id).or(QuestionRelation.where(relation_id: self.id)).destroy_all
  end
end
