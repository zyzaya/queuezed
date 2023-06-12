class Answer < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  belongs_to :question
  has_many :answer_variants, -> { Answer.active }, dependent: :destroy
  has_many :answer_histories, -> { Answer.active }, dependent: :destroy

  def soft_destroy(time = nil)
    if deleted_at.nil?
      update_column(:deleted_at, time.nil? ? Time.now : time)
    end
  end

  def restore(time = nil)
    unless deleted_at.nil?
      if time.nil? || time.eql?(deleted_at)
        update_column(:deleted_at, nil)
      end
    end
  end
end
