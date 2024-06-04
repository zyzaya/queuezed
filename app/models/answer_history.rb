class AnswerHistory < ApplicationRecord
  include SoftDestroyable

  belongs_to :answer
  belongs_to :practice_session

  def correct?
    variants = answer.answer_variants.pluck(:content)
    return variants.include?(given)
  end
end
