class Answer < ApplicationRecord
  include SoftDestroyable

  belongs_to :question
  has_many :answer_variants, -> { Answer.active }, dependent: :destroy
  has_many :answer_histories, -> { Answer.active }, dependent: :destroy
end
