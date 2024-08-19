export default function TagDisplay(tag_id, content) {
  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('tag');
  button.dataset.action = 'question#removeTag';
  button.dataset.questionTarget = 'tag';
  button.dataset.questionTagIdValue = tag_id;
  button.text = content;

  return button;
}
