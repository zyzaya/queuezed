export default function TagDisplay(tag_id, content) {
  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('quiz_edit_tag');
  button.dataset.action = 'edit--question#removeTag';
  button.dataset['edit-QuestionTarget'] = 'tag';
  button.dataset['edit-QuestionTagIdValue'] = tag_id;
  button.text = content;

  return button;
}
