export default function TagDisplay(tag_id, content) {
  let option = document.createElement('option');
  option.value = tag_id;
  option.dataset.questionTarget = 'tagOption';
  option.text = content;

  return option;
}
