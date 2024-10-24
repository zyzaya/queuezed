require "application_system_test_case"
require "test_helper"
require "system/support/practice/practice_actions"
require "system/support/practice/practice_get"

class PracticeTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include PracticeActions
  include PracticeGet

  setup do 
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @valid_questions = @quiz.questions.filter { |q| !q.answers.empty? }
    @initial_sessions = @quiz.practice_sessions.pluck(:id)
    visit new_quiz_practice_path(@quiz)
  end

  test "create a practice session with no filters" do
    start_practice
    practice = get_practice(@quiz.id, @initial_sessions)
    assert_equal "", practice.text_filter
    assert_equal [], practice.tag_filter
    assert_equal @valid_questions, practice.questions
  end

  test "create a practice session with a tag filter" do

  end
  
  test "create a practice session with a text filter" do

  end
end