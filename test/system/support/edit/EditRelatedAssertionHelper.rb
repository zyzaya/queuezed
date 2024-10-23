module EditRelatedAssertionHelper
  def assert_add_related(q_id, related_id, initial)
    assert_equal initial + [related_id.to_s], get_related_questions(q_id)
  end

  def assert_no_change_to_related(q_id, initial)
    assert_equal intial, get_related_questions(q_id)
  end
end