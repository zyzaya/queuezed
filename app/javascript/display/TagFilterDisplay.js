export default function TagDisplay(tag_id, content) {
  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('quiz_edit_tag');
  button.dataset.action = 'filter#removeTag';
  button.dataset.filterTarget = 'tag';
  button.dataset.id = tag_id;
  button.text = content;

  return button;
}
