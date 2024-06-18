class SrsBox < ApplicationRecord
  belongs_to :quiz, counter_cache: :questions_count
  has_many :questions
end
