require "application_system_test_case"
require "test_helper"

class PracticeTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @valid_questions = @quiz.questions.filter { |q| !q.answers.empty? }
    visit new_quiz_practice_path(@quiz)
  end

  test "create a practice session with no filters" do
    initial_ids = @quiz.practice_sessions.pluck(:id)
    click_button('Start')
    new_ids = @quiz.practice_sessions.pluck(:id)
    id = (new_ids - initial_ids)[0]
    practice = PracticeSession.find(id);
    assert_equal "", practice.text_filter
    assert_equal [], practice.tag_filter
    assert_equal @valid_questions, result
  end

  test "create a practice session with a tag filter" do
  
  end
  
  test "create a practice session with a text filter" do

  end
end