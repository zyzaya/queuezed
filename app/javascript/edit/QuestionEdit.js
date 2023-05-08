export default function QuestionEdit() {
  let obj = {};

  let frame = document.getElementById('edit_detail');

  let deleteAnswer = function (event) {
    let answer_id = event.currentTarget.dataset.answer_id;
    let answer_content = document.querySelector(
      `.answer_content[data-answer_id="${answer_id}"]`
    );
    let answer = {
      content: answer_content.value,
    };
    obj.onDeleteAnswer(answer_id, answer);
  };

  let answerContentChange = function (event) {
    let answer_id = event.currentTarget.dataset.answer_id;
    let answer = {
      content: event.currentTarget.value,
      previous: event.currentTarget.dataset.previous,
    };
    obj.onAnswerContentChange(answer_id, answer);
  };

  let questionContentChange = function (event) {
    let question_id = event.currentTarget.dataset.question_id;
    let question = {
      content: event.currentTarget.value,
      previous: event.currentTarget.dataset.previous,
    };
    obj.onQuestionContentChange(question_id, question);
  };

  obj.setQuestionContent = function (question_id, content) {
    let question_content = document.querySelector(
      `.question_content[data-question_id="${question_id}"`
    );
    question_content.value = content;
  };

  obj.addAnswerDisplay = function (question_id, answer_id) {
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
    delete_answer.onclick = deleteAnswer;

    answer_container.appendChild(answer_content);
    answer_container.appendChild(delete_answer);
    add_answer.parentNode.insertBefore(answer_container, add_answer);
  };

  obj.deleteAnswerDisplay = function (id) {
    let answer = document.querySelector(
      `.answer_container[data-answer_id="${id}"]`
    );
    answer.remove();
  };

  obj.setAnswerContent = function (answer_id, content) {
    let answer_content = document.querySelector(
      `.answer_content[data-answer_id="${answer_id}"]`
    );
    answer_content.value = content;
  };

  frame.addEventListener('turbo:frame-render', (event) => {
    // delete question
    document.getElementById('delete_question').onclick = obj.onDeleteQuestion;
    // change question content
    let question_content = document.getElementsByClassName('question_content');
    for (let i = 0; i < question_content.length; i++) {
      question_content[i].onbeforeinput = (event) => {
        event.currentTarget.dataset.previous = event.currentTarget.value;
      };
      question_content[i].oninput = questionContentChange;
    }
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
      delete_answer[i].onclick = deleteAnswer;
    }
    // change answer content
    let answer_content = document.getElementsByClassName('answer_content');
    for (let i = 0; i < answer_content.length; i++) {
      answer_content[i].onbeforeinput = (event) => {
        event.currentTarget.dataset.previous = event.currentTarget.value;
      };
      answer_content[i].oninput = answerContentChange;
    }
  });

  return obj;
}
