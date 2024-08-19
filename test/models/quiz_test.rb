require "test_helper"

class QuizTest < ActiveSupport::TestCase
  test "practice session obeys text_filter" do
    quiz = quizzes(:johns)
    text_filter = "holly"
    practice = quiz.new_practice(text_filter: text_filter)
    practice.save
    result = PracticeSession.find(practice.id)
    result.questions.each do |q|
      assert q.content.downcase.include?(text_filter)
    end
    excluded = result.questions.where.not(id: result.questions.ids)
    excluded.each do |q|
      assert_not q.content.downcase.include?(text_filter)
    end
  end
end
