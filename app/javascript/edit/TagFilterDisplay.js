export default function TagDisplay(tag_id, content) {
  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('tag');
  button.dataset.action = 'zgrid#removeTagFilter';
  button.dataset.zgridTarget = 'tagFilter';
  button.dataset.questionTagIdValue = tag_id;
  button.text = content;

  return button;
}
