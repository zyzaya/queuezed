export default function QuestionEdit() {
  let obj = {};

  let frame = document.getElementById('edit_detail');

  obj.removeAnswerDisplay = function (id) {
    let answer = document.querySelector(
      `.answer_container[data-answer_id="${id}"]`
    );
    answer.remove();
  };

  obj.addAnswer = function () {};

  frame.addEventListener('turbo:frame-render', (event) => {
    // delete question
    document.getElementById('delete_question').onclick = obj.onDeleteQuestion;
    // add answer
    let add_answer = document.getElementsByClassName('add_answer');
    for (let i = 0; i < add_answer.length; i++) {
      add_answer[i].onclick = obj.onAddAnswer;
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
