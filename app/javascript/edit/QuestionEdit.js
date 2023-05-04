export default function QuestionEdit() {
  let obj = {};

  let frame = document.getElementById('edit_detail');

  obj.removeAnswerDisplay = function (id) {
    let answer = document.querySelector(
      `.answer_container[data-answer_id="${id}"]`
    );
    answer.remove();
  };

  obj.addAnswerDisplay = function (question_id) {
    let add_answer = document.querySelector(
      `.add_answer[data-question_id="${question_id}"`
    );

    let answer_container = document.createElement('div');
    answer_container.classList.add('answer_container');

    let answer_content = document.createElement('textarea');
    answer_content.classList.add('answer_content');
    answer_content.rows = '1';

    let delete_answer = document.createElement('a');
    delete_answer.classList.add('button');
    delete_answer.classList.add('delete_answer');
    delete_answer.textContent = '[X]';

    answer_container.appendChild(answer_content);
    answer_container.appendChild(delete_answer);
    add_answer.parentNode.insertBefore(answer_container, add_answer);
  };

  frame.addEventListener('turbo:frame-render', (event) => {
    // delete question
    document.getElementById('delete_question').onclick = obj.onDeleteQuestion;
    // add answer
    let add_answer = document.getElementsByClassName('add_answer');
    for (let i = 0; i < add_answer.length; i++) {
      add_answer[i].onclick = (event) => {
        let question_id = event.currentTarget.dataset.question_id;
        obj.onAddAnswer(question_id);
      };
    }
    // delete answer
    let delete_answer = document.getElementsByClassName('delete_answer');
    for (let i = 0; i < delete_answer.length; i++) {
      delete_answer[i].onclick = (event) => {
        let answer_id = event.currentTarget.dataset.answer_id;
        obj.onDeleteAnswer(answer_id);
      };
    }
  });

  return obj;
}
