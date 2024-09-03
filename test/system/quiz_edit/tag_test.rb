require "application_system_test_case"
require "test_helper"

class TagTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
  end

  def add_tag(content)
    select content, from: "add_tag"
  end

  def remove_tag(content, question_edit)
    button = question_edit.find(".tag_list > a") { |e| e.text.eql?(content) }
    button.click
  end

  def get_tags_content(question_edit)
    question_edit.find_all(".tag_list > a").map do |e|
      e.text
    end
  end

  def assert_add_tag(initial, content, question_edit)
    result = get_tags_content(question_edit)
    assert_equal initial.length + 1, result.length
    assert_equal [content], result - initial
  end

  def assert_remove_tag(initial, content, question_edit)
    result = get_tags_content(question_edit)
    assert_equal initial.length - 1, result.length
    assert_equal [content], initial - result
  end

  def assert_no_change_to_tags(initial, question_edit)
    result = get_tags_content(question_edit)
    assert_equal initial.length, result.length
    assert_empty result - initial
    assert_empty initial - result
  end

  test "add tag -> undo -> redo" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question_edit)
    # redo
    redo_action
    assert_add_tag(initial, tag.content, question_edit)
  end

  test "add tag -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_three)
    tag = tags(:tag_2)    
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # switch selection
    select_question(other.id)
    question_edit = question_edit_container(question.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question_edit)
    # redo
    redo_action
    assert_add_tag(initial, tag.content, question_edit)
  end

  test "add tag -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question_edit)
    # switch selection -> redo
    select_question(other.id)
    redo_action
    question_edit = question_edit_container(question.id)
    assert_add_tag(initial, tag.content, question_edit)
  end

  test "add tag -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_add_tag(initial, tag.content, question_edit)
  end

  test "add tag -> save -> undo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_no_change_to_tags(initial, question_edit)
  end

  test "add tag -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question_edit)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_add_tag(initial, tag.content, question_edit)
  end

  test "remove tag -> undo -> redo" do
    question = questions(:john_one)  
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question_edit)
    # redo
    redo_action
    assert_remove_tag(initial, tag.content, question_edit)
  end

  test "remove tag -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    question_edit = question_edit_container(question.id)
    assert_no_change_to_tags(initial, question_edit)
    # redo
    redo_action
    assert_remove_tag(initial, tag.content, question_edit)
  end

  test "remove tag -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question_edit)
    # switch selection -> redo
    select_question(other.id)
    redo_action
    question_edit = question_edit_container(question.id)
    assert_remove_tag(initial, tag.content, question_edit)
  end

  test "remove tag -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_remove_tag(initial, tag.content, question_edit)
  end

  test "remove tag -> save -> undo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_no_change_to_tags(initial, question_edit)
  end

  test "remove tag -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    initial = get_tags_content(question_edit)
    # remove tag
    remove_tag(tag.content, question_edit)
    assert_remove_tag(initial, tag.content, question_edit)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    question_edit = question_edit_container(question.id)
    assert_remove_tag(initial, tag.content, question_edit)
  end

  # add tag -> undo -> redo
  # add tag -> switch selection -> undo -> redo
  # add tag -> undo -> switch selection -> reo
  # add tag -> save
  # add tag -> save -> undo -> save
  # add tag -> save -> undo -> save -> redo -> save
  # remove tag -> undo -> redo
  # remove tag -> switch selection -> undo -> redo
  # remove tag -> undo -> switch selection -> reo
  # remove tag -> save
  # remove tag -> save -> undo -> save
  # remove tag -> save -> undo -> save -> redo -> save
  # create new tag -> undo -> redo
  # create new tag -> switch selection -> undo -> redo
  # create new tag -> undo -> switch selection -> reo
  # create new tag -> save
  # create new tag -> save -> undo -> save
  # create new tag -> save -> undo -> save -> redo -> save
end