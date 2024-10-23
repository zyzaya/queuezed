require "application_system_test_case"
require "test_helper"

class RelatedTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)

    visit_edit_page(@quiz)
    select_question(@question.id)
  end

  test "add relation select displays all potential questions" do
    expected = @quiz.questions.order(:content).pluck(:content)
    assert_equal expected, get_add_related_options
  end

  test "add relation select can be limited" do
    filter = "Reverse"
    filter_by_text(filter)
    page.find("#limit_add_related").check()
    expected = @quiz.questions.order(:content).pluck(:content).filter do |q|
      q.include?(filter)
    end
    assert_equal expected, get_add_related_options
  end

  test "add relation select is not limited if check not selected" do
    filter = "Reverse"
    filter_by_text(filter)
    expected = @quiz.questions.order(:content).pluck(:content)
    assert_equal expected, get_add_related_options
  end
end