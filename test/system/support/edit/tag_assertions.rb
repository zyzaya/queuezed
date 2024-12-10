module TagAssertions
  def assert_add_tag(q_id, initial, content)
    assert_equal (initial + [content]).sort, get_tags_content(q_id)
  end

  def assert_remove_tag(q_id, initial, content)
    assert_equal (initial - [content]).sort, get_tags_content(q_id)
  end

  def assert_create_tag(q_id, initial_options, initial_content, content)
    assert_add_tag(q_id, initial_content, content)
    expected = (initial_options + [content]).sort
    # add to add tag options
    assert_equal expected, get_add_tag_options(q_id)
    # add to filter by tag options
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tags(q_id, initial_content, initial_options)
    result = get_tags_content(q_id)
    assert_equal initial_content, result, "assert_no_change_to_tags: tags are not equal to initial"
    assert_no_change_to_tag_options(q_id, initial_options)
  end

  def assert_remove_tag_option(q_id, initial, option)
    expected = (initial - [option]).sort
    name = "assert_remove_tag_option"
    assert_equal expected, get_add_tag_options(q_id), "#{name}: add tag options are not equal"
    assert_equal expected, get_filter_tag_options, "#{name}: filter tag options are not equal"
  end

  def assert_no_change_to_tag_options(q_id, initial_options)
    name = "assert_no_change_to_tag_options"
    assert_equal initial_options, get_add_tag_options(q_id), "#{name}: add tag options are not equal to initial"
    assert_equal initial_options, get_filter_tag_options, "#{name}: filter tag options are not equal to initial"
  end
end