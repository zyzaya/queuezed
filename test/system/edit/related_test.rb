require "application_system_test_case"
require "test_helper"

class RelatedTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @relation = questions(:john_three)
    @add_relation_options = 
      @quiz
        .questions
        .order(:content)
        .where
        .not(id: @question.id)
        .pluck(:content)
    visit_edit_page(@quiz)
    select_question(@question.id)
    @initial = get_relations(@question.id)
  end

  test "add relation select displays all potential questions" do
    expected = @quiz.questions.order(:content).pluck(:content)
    assert_equal @add_relation_options, get_add_relation_options
  end

  test "add relation select can be limited" do
    filter = "Reverse"
    filter_by_text(filter)
    page.find("#limit_add_related").check()
    expected = @add_relation_options.filter do |q|
      q.include?(filter)
    end
    assert_equal expected, get_add_relation_options
  end

  test "add relation select is not limited if check not selected" do
    filter = "Reverse"
    filter_by_text(filter)
    assert_equal @add_relation_options, get_add_relation_options
  end

  test "add relation -> undo -> redo" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # undo
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # redo
    redo_action
    assert_add_relation(@question.id, @other.id, @initial)
  end

  test "add relation -> switch selection -> undo -> redo" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # redo
    redo_action
    assert_add_relation(@question.id, @other.id, @initial)
  end

  test "add relation -> undo -> switch selection -> redo" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # undo
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_add_relation(@question.id, @other.id, @initial)
  end

  test "add relation -> save" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # save
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_add_relation(@question.id, @other.id, @initial)
  end

  test "add relation -> save -> undo -> save" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_no_change_to_relations(@question.id, @initial)
  end

  test "add relation -> save -> undo -> save -> redo -> save" do
    # add relation
    add_relation(@other.content)
    assert_add_relation(@question.id, @other.id, @initial)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_add_relation(@question.id, @other.id, @initial)
  end

  test "remove relation -> undo -> redo" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # undo
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # redo
    redo_action
    assert_remove_relation(@question.id, @relation.id, @initial)
  end

  test "remove relation -> switch selection -> undo -> redo" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # redo
    redo_action
    assert_remove_relation(@question.id, @relation.id, @initial)
  end

  test "remove relation -> undo -> switch selection -> redo" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # undo
    undo_action
    assert_no_change_to_relations(@question.id, @initial)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_remove_relation(@question.id, @relation.id, @initial)
  end

  test "remove relation -> save" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # save
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
  end

  test "remove relation -> save -> undo -> save" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_no_change_to_relations(@question.id, @initial)
  end

  test "remove relation -> save -> undo -> save -> redo -> save" do
    # remove relation
    remove_relation(@relation.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_remove_relation(@question.id, @relation.id, @initial)
  end
end