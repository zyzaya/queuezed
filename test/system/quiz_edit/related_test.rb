require "application_system_test_case"
require "test_helper"

class RelatedTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @add_related_options = 
      @quiz
        .questions
        .order(:content)
        .where
        .not(id: @question.id)
        .pluck(:content)

    visit_edit_page(@quiz)
    select_question(@question.id)
    @initial = get_related_questions(@question.id)
  end

  test "add relation select displays all potential questions" do
    expected = @quiz.questions.order(:content).pluck(:content)
    assert_equal @add_related_options, get_add_related_options
  end

  test "add relation select can be limited" do
    filter = "Reverse"
    filter_by_text(filter)
    page.find("#limit_add_related").check()
    expected = @add_related_options.filter do |q|
      q.include?(filter)
    end
    assert_equal expected, get_add_related_options
  end

  test "add relation select is not limited if check not selected" do
    filter = "Reverse"
    filter_by_text(filter)
    assert_equal @add_related_options, get_add_related_options
  end

  test "add related -> undo -> redo" do
    # add related
    add_related(@other.content)
    assert_add_related(@question.id, @other.id, @initial)
    # undo
    undo_action
    assert_no_change_to_related(@question.id, @initial)
    # redo
    redo_action
    assert_add_related(@question.id, @other.id, @initial)
  end

  # add related -> undo -> redo
  # add related -> switch selection -> undo -> redo
  # add related -> undo -> switch selection -> undo -> redo
  # add related -> save 
  # add related -> save -> undo -> save
  # add related -> save -> undo -> save -> redo -> save
  # edit content of related
  # add answer of related
  # remove answer of related
  # edit content of answer in related
end