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

  def get_tags_content
    page.find_all(".tag_list > a").map do |e|
      e.text
    end
  end

  def assert_add_tag(initial, content)
    result = get_tags_content
    assert_equal initial.length + 1, result.length
    assert_equal [content], result - initial
  end

  def assert_no_change_to_tags(initial)
    result = get_tags_content
    assert_equal initial.length, result.length
    assert_empty result - initial
    assert_empty initial - result
  end

  test "add tag -> undo -> redo" do
    question = questions(:john_one)
    tag = tags(:tag_2)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = get_tags_content
    # add tag
    add_tag(tag.content)
    assert_add_tag(initial, tag.content)
    # undo
    undo_action
    assert_no_change_to_tags(initial)
    # redo
    redo_action
    assert_add_tag(initial, tag.content)
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