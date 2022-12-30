class Question < ApplicationRecord
  belongs_to :srs_box
  has_and_belongs_to_many :tags
end
