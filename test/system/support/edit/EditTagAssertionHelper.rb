module EditTagAssertionHelper
  def assert_add_tag(initial, content)
    assert_equal (initial + [content]).sort, get_tags_content
  end

  def assert_remove_tag(initial, content)
    assert_equal (initial - [content]).sort, get_tags_content
  end

  def assert_create_tag(q_id, initial_options, initial_content, content)
    assert_add_tag(initial_content, content)
    expected = (initial_options + [content]).sort
    # add to add tag options
    assert_equal expected, get_add_tag_options(q_id)
    # add to filter by tag options
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tags(initial_content, initial_options)
    result = get_tags_content
    assert_equal initial_content, result
    assert_no_change_to_tag_options(initial_options)
  end

  def assert_remove_tag_option(q_id, initial, option)
    expected = (initial - [option]).sort
    assert_equal expected, get_add_tag_options(q_id)
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tag_options(q_id, initial_options)
    assert_equal initial_options, get_add_tag_options(q_id)
    assert_equal initial_options, get_filter_tag_options
  end
end