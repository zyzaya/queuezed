module AnswerAssertions
  def assert_answer_content(id, content)
    textarea = answer_container(id).find("textarea")
    assert_equal content, textarea.value
  end

  def assert_add_answer(q_id, initial)
    assert_equal initial + [""], get_answers_content(q_id)
  end

  def assert_delete_answer(q_id, initial, content)
    assert_equal initial - [content], get_answers_content(q_id)
  end

  def assert_no_change_to_answers(q_id, initial)
    assert_equal initial, get_answers_content(q_id)
  end
end