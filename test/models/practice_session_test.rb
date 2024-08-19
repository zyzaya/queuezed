require "test_helper"

class PracticeSessionTest < ActiveSupport::TestCase
  test "current_questions gets current question set" do
    practice = quizzes(:johns).new_practice
    practice.save
    result = PracticeSession.find(practice.id)
    questions = result.current_questions
    questions.each do |q|
      assert practice.order[practice.current].include?(q.id)
    end
  end
end
