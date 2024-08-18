class Answer < ApplicationRecord
  include SoftDestroyable

  belongs_to :question
  has_many :histories, -> { AnswerHistory.active }, dependent: :destroy, class_name: 'AnswerHistory'

  def variants
    self.content.split(/ ?\/ ?/)
  end
end
