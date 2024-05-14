export default function TagDisplay(parent, tag_id, content) {
  let obj = {};

  let button = document.createElement('a');
  button.classList.add('button');
  button.classList.add('tag');
  button.text = content;

  parent.appendChild(button);
  return obj;
}
