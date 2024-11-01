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

  test "practice session obeys tag_filter" do
    quiz = quizzes(:johns)
    tag_filter = [tags(:tag_1).id]
    practice = quiz.new_practice(tag_filter: tag_filter)
    practice.save
    result = PracticeSession.find(practice.id)
    result.questions.each do |q|
      assert_not_nil q.tags.find_by(id: tags(:tag_1).id)
    end
    excluded = practice.questions.where.not(id: practice.questions.ids)
    excluded.each do |q|
      assert_nil q.tags.find_by(id: tags(:tag_1).id)
    end
  end

  test "practice session obeys review filter" do
    quiz = quizzes(:johns)
    practice = quiz.new_practice(review: true)
    practice.save
    result = PracticeSession.find(practice.id)
    result.questions.each { |q| assert q.review }
    excluded = result.questions.where.not(id: result.questions.ids)
    excluded.each { |q| assert_not q.review }
  end

  test "practice session does not include questions without an answer" do
    practice = quizzes(:johns).new_practice
    practice.save
    result = PracticeSession.find(practice.id)
    result.questions.each do |q|
      assert q.answers.count > 0
    end
  end

  test "new_practice returns nil if no valid questions are found" do
    practice = quizzes(:johns).new_practice(text_filter: "no questions have this text")
    assert_nil practice
  end

  test "new_practice obeys limit" do
    practice = quizzes(:johns).new_practice(limit: 1)
    assert practice.questions.length, 1
  end
end
