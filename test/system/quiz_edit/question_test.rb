require "application_system_test_case"
require "test_helper"

class QuestionTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    visit edit_quiz_path(@quiz)
    @initial = get_questions_content
  end

  def add_question
    page.find("#new_question").click
  end

  def assert_add_question
    assert_equal @initial + [""], get_questions_content
  end

  def assert_no_change_to_questions
    assert_equal @initial, get_questions_content
  end

  test "add question -> undo -> redo" do
    # add question
    add_question
    assert_add_question
    # undo
    undo_action
    assert_no_change_to_questions
    # redo
    redo_action
    assert_add_question
  end

  # add question -> undo -> redo
  # add question -> switch selection -> undo -> redo
  # add question -> und -> switch selection -> redo
  # add question -> save
  # add question -> save -> undo -> save
  # add question -> save -> undo -> redo -> save
  # delete question -> undo -> redo
  # delete question -> switch selection -> undo -> redo
  # delete question -> und -> switch selection -> redo
  # delete question -> save
  # delete question -> save -> undo -> save
  # delete question -> save -> undo -> redo -> save
  # change question content -> undo -> redo
  # change question content -> switch selection -> undo -> redo
  # change question content -> und -> switch selection -> redo
  # change question content -> save
  # change question content -> save -> undo -> save
  # change question content -> save -> undo -> redo -> save
end