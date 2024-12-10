export default function AnswerDisplay(
  parent,
  question_id,
  answer_id,
  content = '',
  index = -1
) {
  let obj = {};

  let add_answer = parent.querySelector(`.question_edit_single_add_answer`);

  let answer_container = document.createElement('div');
  answer_container.classList.add('question_edit_answer_container');
  answer_container.dataset.controller = 'edit--answer';
  answer_container.dataset['edit-AnswerQuestionIdValue'] = question_id;
  answer_container.dataset['edit-AnswerIdValue'] = answer_id;
  answer_container.dataset[
    'edit-AnswerSingleQuestionOutlet'
  ] = `.question_edit_single[data-edit--single-question-id-value="${question_id}"]`;
  answer_container.dataset.action = 'keydown.alt+shift+a->edit--answer#delete';

  let answer_content = document.createElement('textarea');
  answer_content.id = `answer_content#${answer_id}`;
  answer_content.classList.add('question_edit_answer_content');
  answer_content.rows = '1';
  answer_content.dataset.editTarget = 'answerContent';
  answer_content.dataset['edit-AnswerTarget'] = 'info';
  answer_content.dataset.action = 'edit--answer#answerContentChange';
  answer_content.value = content;

  let delete_answer = document.createElement('a');
  delete_answer.classList.add('button');
  delete_answer.classList.add('question_edit_answer_delete');
  delete_answer.dataset.action = 'edit--answer#delete';
  delete_answer.textContent = '[X]';

  answer_container.appendChild(answer_content);
  answer_container.appendChild(delete_answer);
  let answers = parent.querySelectorAll('.question_edit_answer_container');
  if (index < 0 || index >= answers.length) {
    parent.insertBefore(answer_container, add_answer);
  } else {
    parent.insertBefore(answer_container, answers[index]);
  }

  obj.focus = () => {
    answer_content.focus();
  };

  return obj;
}
