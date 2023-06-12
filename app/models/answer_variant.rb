class AnswerVariant < ApplicationRecord
  include SoftDestroyable

  belongs_to :answer
end
