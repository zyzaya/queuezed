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
    result = get_add_related_options
    assert_equal expected, result
  end

  test "add relation select can be limited" do
  end
end