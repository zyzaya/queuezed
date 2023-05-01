class Question < ApplicationRecord
  belongs_to :srs_box
  has_and_belongs_to_many :tags
  has_many :answers, dependent: :destroy
  has_many :question_histories, dependent: :destroy
  has_many :question_relations
  has_many :relations, through: :question_relations, class_name: 'Question'

  before_destroy :destroy_relations
  private
  def destroy_relations
    QuestionRelation.where(question_id: self.id).or(QuestionRelation.where(relation_id: self.id)).destroy_all
  end
end
