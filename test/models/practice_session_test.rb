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

  test "next question increments current" do
    practice = quizzes(:johns).new_practice
    initial = practice.current
    practice.save
    result = PracticeSession.find(practice.id)
    result.next_question
    assert_equal initial + 1, result.current
  end

  test "finished returns false when not finished" do
    practice = quizzes(:johns).new_practice
    practice.save
    result = PracticeSession.find(practice.id)
    assert_not result.finished?
  end

  test "finished resturns true when finished" do
    practice = quizzes(:johns).new_practice
    practice.save
    result = PracticeSession.find(practice.id)
    result.update(current: result.length + 1)
    assert result.finished?
  end
end
