require "application_system_test_case"
require "test_helper"

class TagTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
    @question = questions(:john_one)
    @has_tag = tags(:tag_1)
    @other = questions(:john_two)
    @not_has_tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    @initial = get_tags_content
  end

  def add_tag(content)
    select content, from: "add_tag"
  end

  def remove_tag(content)
    container = question_edit_container(@question.id)
    button = container.find(".tag_list > a") { |e| e.text.eql?(content) }
    button.click
  end

  def get_tags_content
    container = question_edit_container(@question.id)
    container.find_all(".tag_list > a").map do |e|
      e.text
    end
  end

  def assert_add_tag(content)
    result = get_tags_content
    assert_equal @initial.length + 1, result.length
    assert_equal [content], result - @initial
  end

  def assert_remove_tag(content)
    result = get_tags_content
    assert_equal @initial.length - 1, result.length
    assert_equal [content], @initial - result
  end

  def assert_no_change_to_tags
    result = get_tags_content
    assert_equal @initial.length, result.length
    assert_empty result - @initial
    assert_empty @initial - result
  end

  test "add tag -> undo -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_add_tag(@not_has_tag.content)
  end

  test "add tag -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_three)
    tag = tags(:tag_2)    
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question.id)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question.id)
    # redo
    redo_action
    assert_add_tag(initial, tag.content, question.id)
  end

  test "add tag -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question.id)
    # switch selection -> redo
    select_question(other.id)
    redo_action
    assert_add_tag(initial, tag.content, question.id)
  end

  test "add tag -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question.id)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_add_tag(initial, tag.content, question.id)
  end

  test "add tag -> save -> undo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question.id)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_no_change_to_tags(initial, question.id)
  end

  test "add tag -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content, question.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_add_tag(initial, tag.content, question.id)
  end

  test "remove tag -> undo -> redo" do
    question = questions(:john_one)  
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question.id)
    # redo
    redo_action
    assert_remove_tag(initial, tag.content, question.id)
  end

  test "remove tag -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question.id)
    # redo
    redo_action
    assert_remove_tag(initial, tag.content, question.id)
  end

  test "remove tag -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # undo
    undo_action
    assert_no_change_to_tags(initial, question.id)
    # switch selection -> redo
    select_question(other.id)
    redo_action
    assert_remove_tag(initial, tag.content, question.id)
  end

  test "remove tag -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_remove_tag(initial, tag.content, question.id)
  end

  test "remove tag -> save -> undo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_no_change_to_tags(initial, question.id)
  end

  test "remove tag -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    tag = tags(:tag_1)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content(question.id)
    # remove tag
    remove_tag(tag.content, question.id)
    assert_remove_tag(initial, tag.content, question.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_remove_tag(initial, tag.content, question.id)
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