import QuestionList from 'edit/QuestionList';
import Change from 'edit/Change';
import QuestionEdit from 'edit/QuestionEdit';
import Undo from 'edit/Undo';
import ID from 'edit/ID';

console.log('yes this this working');

let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
let quiz_id = document.getElementById('quizzes_edit').dataset.quiz_id;

let question_list = QuestionList(csrf, quiz_id);
let change = Change(csrf, quiz_id);
let question_edit = QuestionEdit();
let undo = Undo();

let btn_undo = document.getElementById('undo');
btn_undo.onclick = undo.undo;
let btn_redo = document.getElementById('redo');
btn_redo.onclick = undo.redo;

question_edit.onDeleteAnswer = (answer_id, answer) => {
  let question_id = question_list.getCurrentlySelectedID();

  let action = () => {
    change.deleteAnswer(question_id, answer_id);
    question_edit.deleteAnswerDisplay(answer_id);
  };
  let reverse = () => {
    change.addAnswer(question_id, answer_id);
    change.setAnswerContent(question_id, answer_id, answer.content);
    question_edit.addAnswerDisplay(question_id, answer_id);
    question_edit.setAnswerContent(answer_id, answer.content);
  };
  undo.add('Delete Answer', action, reverse);
};

question_edit.onAddAnswer = (question_id) => {
  let answer_id = ID.next();
  let action = () => {
    change.addAnswer(question_id, answer_id);
    question_edit.addAnswerDisplay(question_id, answer_id);
  };
  let reverse = () => {
    change.deleteAnswer(question_id, answer_id);
    question_edit.deleteAnswerDisplay(answer_id);
  };
  undo.add('Add Answer', action, reverse);
};

question_edit.onAnswerContentChange = (answer_id, answer) => {
  let question_id = question_list.getCurrentlySelectedID();

  let action = () => {
    change.setAnswerContent(question_id, answer_id, answer.content);
    question_edit.setAnswerContent(answer_id, answer.content);
  };
  let reverse = () => {
    change.setAnswerContent(question_id, answer_id, answer.previous);
    question_edit.setAnswerContent(answer_id, answer.previous);
  };
  undo.add('Change Answer Content', action, reverse);
};

question_edit.onQuestionContentChange = (question_id, question) => {
  let action = () => {
    change.setQuestionContent(question_id, question.content);
    question_edit.setQuestionContent(question_id, question.content);
  };
  let reverse = () => {
    change.setQuestionContent(question_id, question.previous);
    question_edit.setQuestionContent(question_id, question.previous);
  };
  undo.add('Change Question Content', action, reverse);
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
// saving
let btn_save = document.getElementById('save');
btn_save.onclick = (event) => {
  console.log(change.getChanges());
  // server save
  fetch(`/quizzes/${quiz_id}/update`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrf,
    },
    credentials: 'same-origin',
    body: JSON.stringify(change.getChanges()),
  });
  // turbo visit replace q detail
  // reset change object
};
