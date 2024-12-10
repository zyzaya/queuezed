require "application_system_test_case"
require "test_helper"
require "system/support/practice/practice_actions"
require "system/support/practice/practice_get"
require "system/support/practice/practice_assertions"

class PracticeTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include PracticeActions
  include PracticeGet
  include PracticeAssertions

  setup do 
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @valid_questions = @quiz.questions.filter { |q| !q.answers.empty? }
    @initial_sessions = @quiz.practice_sessions.pluck(:id)
    visit new_quiz_practice_path(@quiz)
    sleep(0.3)
  end

  test "create a practice session with no filters" do
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    assert_equal "", practice.text_filter
    assert_equal [], practice.tag_filter
    assert_equal @valid_questions, practice.questions
  end

  test "create a practice session with a tag filter" do
    tag = @quiz.tags.first
    add_practice_tag_filter(tag.content)
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    assert_equal [tag.id], practice.tag_filter
    assert practice.questions.all? { |q| q.tags.include?(tag) }
  end
  
  test "create a practice session with a text filter" do
    text = "reverse"
    add_practice_text_filter(text)
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    assert_equal text, practice.text_filter
    assert practice.questions.all? { |q| q.content.downcase.include?(text) }
  end

  test "answer a question correctly" do
    start_practice
    given = submit_answers(true)
    assert_question_feedback(given)
  end

  test "answer a question incorrectly" do
    start_practice
    given = submit_answers(false)
    assert_question_feedback(given)
  end

  test "feedback" do
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    length = practice.questions.count
    given = []
    1.upto(length) do |_|
      given << submit_answers(true)
      page.find(".practice_form_next").click
      # wait for page / turbo to fully load
      sleep(0.5)
    end
    given.each do |g|
      assert_question_feedback(g)
    end
  end

  test "continue" do
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    visit new_quiz_practice_path(@quiz)
    assert page.has_selector?(".button[href=\"#{practice_path(practice)}\"]")
  end
end