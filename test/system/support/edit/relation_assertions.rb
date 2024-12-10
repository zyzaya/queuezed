module RelationAssertions
  def assert_add_relation(q_id, related_id, initial)
    assert_equal(
      initial + [related_id.to_s],
      get_relations(q_id),
      "assert_add_relation:"
    )
  end

  def assert_remove_relation(q_id, related_id, initial)
    assert_equal(
      initial - [related_id.to_s],
      get_relations(q_id), 
      "assert_remove_relation:"
    )
  end

  def assert_no_change_to_relations(q_id, initial)
    assert_equal(
      initial,
      get_relations(q_id),
      "assert_no_change_to_relations: relations are not equal not initial"
    )
  end
end