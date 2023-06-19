import QuestionList from 'edit/QuestionList';
import Change from 'edit/Change';
import QuestionEdit from 'edit/QuestionEdit';
import Undo from 'edit/Undo';
import ID from 'edit/ID';
import Data from 'edit/Data';
import { Grid, html } from 'gridjs';
import { RowSelection } from 'selection';

console.log('yes this this working');

new Grid({
  columns: ['Name', 'Email', 'Phone Number'],
  data: [
    ['John', 'john@example.com', '(353) 01 222 3333'],
    ['Mark', 'mark@gmail.com', '(01) 22 888 4444'],
    ['Eoin', 'eoin@gmail.com', '0097 22 654 00033'],
    ['Sarah', 'sarahcdd@gmail.com', '+322 876 1233'],
    ['Afshin', 'afshin@mail.com', '(353) 22 87 8356'],
  ],
  search: true,
  sort: true,
}).render(document.getElementById('gridjs_test'));

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
  let question_id = question_list.getCurrentlySelectedID();
  let action = () => {
    Data.deleteQuestion(csrf, quiz_id, question_id).then(() => {
      question_list.setSelectedToSibling();
      question_list.removeRow(question_id);
    });
  };
  let reverse = () => {
    Data.restoreQuestion(csrf, quiz_id, question_id)
      .then((response) => response.json())
      .then((question) => {
        question_list.addRow(question);
        question_list.setSelectedQuestion(question_id);
      });
  };
  undo.add('Delete Question', action, reverse);
}
question_edit.onDeleteQuestion = deleteQuestion;

let new_question = document.getElementById('new_question');

new_question.onclick = (e) => {
  let question = Data.newQuestion(csrf, quiz_id).then((question) => {
    question_list.addRow(question);
  });
};
// saving
let btn_save = document.getElementById('save');
btn_save.onclick = () => {
  Data.save(csrf, quiz_id, change.getChanges());
};
