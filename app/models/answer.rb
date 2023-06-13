class Answer < ApplicationRecord
  include SoftDestroyable

  belongs_to :question
  has_many :answer_variants, -> { AnswerVariant.active }, dependent: :destroy
  has_many :answer_histories, -> { AnswerHistory.active }, dependent: :destroy
end
