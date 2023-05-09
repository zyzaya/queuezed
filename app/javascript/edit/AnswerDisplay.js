export default function AnswerDisplay(question_id, answer_id) {
  let obj = {};

  let add_answer = document.querySelector(
    `.add_answer[data-question_id="${question_id}"`
  );

  let answer_container = document.createElement('div');
  answer_container.classList.add('answer_container');
  answer_container.dataset.answer_id = answer_id;

  let answer_content = document.createElement('textarea');
  answer_content.classList.add('answer_content');
  answer_content.rows = '1';
  answer_content.dataset.answer_id = answer_id;

  let delete_answer = document.createElement('a');
  delete_answer.classList.add('button');
  delete_answer.classList.add('delete_answer');
  delete_answer.textContent = '[X]';
  delete_answer.dataset.answer_id = answer_id;
  delete_answer.onclick = (event) => {
    if (typeof obj.onDelete === 'function') {
      obj.onDelete(event);
    }
  };

  answer_container.appendChild(answer_content);
  answer_container.appendChild(delete_answer);
  add_answer.parentNode.insertBefore(answer_container, add_answer);

  return obj;
}
