module EditAnswerAssertionHelper
  def assert_answer_content(id, content)
    textarea = answer_container(id).find("textarea")
    assert_equal content, textarea.value
  end

  def assert_add_answer(initial)
    assert_equal initial + [""], get_answers_content
  end

  def assert_delete_answer(initial, content)
    assert_equal initial - [content], get_answers_content
  end

  def assert_no_change_to_answers(initial)
    assert_equal initial, get_answers_content
  end
end