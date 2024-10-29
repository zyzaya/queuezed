export default function TagDisplay(tag_id, content) {
  let option = document.createElement('option');
  option.value = tag_id;
  option.text = content;
  option.dataset['edit-QuestionTarget'] = 'tagOption';

  return option;
}
