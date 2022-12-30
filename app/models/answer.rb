class Answer < ApplicationRecord
  belongs_to :question
  has_many :answer_variants
  has_many :answer_histories
end
