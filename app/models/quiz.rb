class Quiz < ApplicationRecord
  belongs_to :user
  has_many :srs_boxes
  has_many :questions, through: :srs_boxes
end
