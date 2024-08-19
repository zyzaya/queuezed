export default function AnswerDisplay(
  parent,
  question_id,
  answer_id,
  content = ''
) {
  let obj = {};

  let add_answer = parent.querySelector(`.add_answer`);

  let answer_container = document.createElement('div');
  answer_container.classList.add('answer_container');
  answer_container.dataset.controller = 'answer';
  answer_container.dataset.answerQuestionIdValue = question_id;
  answer_container.dataset.answerIdValue = answer_id;
  answer_container.dataset.answerSingleQuestionOutlet = `.single_question_edit[data-single-question-id-value="${question_id}"]`;

  let answer_content = document.createElement('textarea');
  answer_content.classList.add('answer_content');
  answer_content.rows = '1';
  answer_content.dataset.editTarget = 'answerContent';
  answer_content.dataset.answerTarget = 'info';
  answer_content.dataset.action = 'answer#answerContentChange';
  answer_content.value = content;

  let delete_answer = document.createElement('a');
  delete_answer.classList.add('button');
  delete_answer.classList.add('delete_answer');
  delete_answer.dataset.action = 'answer#delete';
  delete_answer.textContent = '[X]';

  answer_container.appendChild(answer_content);
  answer_container.appendChild(delete_answer);
  parent.insertBefore(answer_container, add_answer);

  obj.focus = () => {
    answer_content.focus();
  };

  return obj;
}
