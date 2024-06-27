export default function TagDisplay(tag_id, content) {
  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('tagFilter');
  button.dataset.action = 'filter#removeTagFilter';
  button.dataset.filterTarget = 'tag';
  button.dataset.id = tag_id;
  button.text = content;

  return button;
}
