class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions, -> { Question.active }, dependent: :destroy
  has_many :tags, through: :questions
  has_many :practice_sessions

  after_initialize :init

  accepts_nested_attributes_for :questions, allow_destroy: true

  def init
    self.rank_1_interval = 1.days.to_i
    self.rank_2_interval = 3.days.to_i
    self.rank_3_interval = 1.week.to_i
    self.rank_4_interval = 1.month.to_i
    self.rank_5_interval = 4.months.to_i
  end

  def interval_duration(rank)
    duration = nil
    case rank
    when 0
      duration = 0
    when 1
      duration = self.rank_1_interval
    when 2
      duration = self.rank_2_interval
    when 3
      duration = self.rank_3_interval
    when 4
      duration = self.rank_4_interval
    when 5
      duration = self.rank_5_interval
    else
    end
    ActiveSupport::Duration.build(duration) unless duration.nil?
  end
end
