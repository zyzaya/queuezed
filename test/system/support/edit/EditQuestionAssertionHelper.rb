module EditQuestionAssertionHelper
  def assert_add_question(initial)
    assert_equal initial + [""], get_questions_content
  end

  def assert_delete_question(initial, content)
    assert_equal (initial - [content]).sort, get_questions_content.sort
  end

  def assert_no_change_to_questions(initial)
    assert_equal initial.sort, get_questions_content.sort
  end

  def assert_question_content(id, content)
    assert_equal content, get_single_question_content(id)
    assert_includes get_questions_content, content
  end
end
