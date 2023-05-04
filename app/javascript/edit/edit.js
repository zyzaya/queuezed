import QuestionList from 'edit/QuestionList';
import Change from 'edit/Change';
import QuestionEdit from 'edit/QuestionEdit';
import Undo from 'edit/Undo';

console.log('yes this this working');

let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
let changes = { a: '' };
let quiz_id = document.getElementById('quizzes_edit').dataset.quiz_id;

let question_list = QuestionList(csrf, quiz_id);
let change = Change(csrf, quiz_id);
let question_edit = QuestionEdit();
let undo = Undo();

let current = 0;
let nextID = function () {
  current++;
  return `n${current}`;
};

question_edit.onDeleteAnswer = (answer_id) => {
  let question_id = question_list.getCurrentlySelectedID();
  change.deleteAnswer(question_id, answer_id);
  question_edit.removeAnswerDisplay(answer_id);
};

question_edit.onAddAnswer = (question_id) => {
  let answer_id = nextID();
  let action = () => {
    change.addAnswer(question_id, answer_id);
    question_edit.addAnswerDisplay(question_id, answer_id);
  };
  let reverse = () => {
    change.deleteAnswer(question_id, answer_id);
    question_edit.removeAnswerDisplay(answer_id);
  };
  undo.add('Add Answer', action, reverse);
};

function deleteQuestion(id) {
  // server delete
  fetch(
    `/quizzes/${quiz_id}/edit/questions/${question_list.getCurrentlySelectedID()}`,
    {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
    }
  );
  // set question to sibling id
  question_list.setSelectedToSibling();
  question_list.removeRow(question_list.getPreviouslySelectedID());
}
question_list.onDeleteQuestion = deleteQuestion;

let new_question = document.getElementById('new_question');

new_question.onclick = (e) => {
  console.log('new question');
  console.log(quiz_id);
  fetch(`/quizzes/${quiz_id}/edit/questions/new`)
    .then((response) => response.json())
    .then((question) => {
      console.log(question);
      previous_id = current_id;
      current_id = question.id;
      Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${current_id}/edit`, {
        frame: 'edit_detail',
        action: 'replace',
      });
      question_list.addRow(question);
    });
};
