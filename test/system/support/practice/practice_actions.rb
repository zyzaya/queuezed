module PracticeActions
  def start_practice
    click_button('Start')
  end

  def add_practice_tag_filter(content)
    select content, from: "edit_add_tag_filter"
  end

  def add_practice_text_filter(text)
    input = page.find("edit_filter")
    input.send_keys(text)
    input.send_keys(:return)
  end
end