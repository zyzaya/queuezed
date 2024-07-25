class Quiz < ApplicationRecord
  belongs_to :user
  has_many :srs_boxes
  has_many :questions, -> { Question.active }, through: :srs_boxes
  has_many :tags, through: :questions
  has_many :practice_sessions

  after_initialize :init

  def init
    self.rank_1_interval = 1.days.to_i
    self.rank_2_interval = 3.days.to_i
    self.rank_3_interval = 1.week.to_i
    self.rank_4_interval = 1.month.to_i
    self.rank_5_interval = 4.months.to_i
  end
end
