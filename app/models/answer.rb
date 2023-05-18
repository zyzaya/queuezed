class Answer < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  belongs_to :question
  has_many :answer_variants, -> { Answer.active }, dependent: :destroy
  has_many :answer_histories, -> { Answer.active }, dependent: :destroy
end
