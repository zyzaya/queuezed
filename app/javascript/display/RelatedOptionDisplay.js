export default function TagOptionDisplay(id, content) {
  let option = document.createElement('option');
  option.value = id;
  option.text = content;
  option.dataset['edit-QuestionTarget'] = 'addRelatedOption';
  return option;
}
