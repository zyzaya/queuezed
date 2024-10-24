module EditRelationAssertionHelper
  def assert_add_relation(q_id, related_id, initial)
    assert_equal initial + [related_id.to_s], get_relations(q_id)
  end

  def assert_no_change_to_relations(q_id, initial)
    assert_equal initial, get_relations(q_id)
  end
end