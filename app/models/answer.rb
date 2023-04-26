class Answer < ApplicationRecord
  belongs_to :question
  has_many :answer_variants, dependent: :destroy
  has_many :answer_histories, dependent: :destroy
end
