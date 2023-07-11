import Data from 'edit/Data';
import QuestionTable from 'edit/QuestionTable';

export default function QuestionList(csrf, quiz_id) {
  let obj = {};
  let question_table = QuestionTable(
    document.getElementById('gridjs'),
    quiz_id
  );
  let previously_selected_id = null;
  let currently_selected_id = null;

  question_table.onRowClick = function (event, data) {
    obj.setSelectedQuestion(data.cells[0].data);
  };

  let getRow = function (id) {
    // get row element that contains id column of value /id/
    let cell = document.querySelector(`.gridjs-td[data-question_id="${id}"]`);
    if (cell === null) return null;

    return cell.parentNode;
  };

  // public functions
  obj.getCurrentlySelectedID = () => currently_selected_id;
  obj.getPreviouslySelectedID = () => previously_selected_id;

  obj.setSelectedToSibling = function () {
    let current = getRow(currently_selected_id);
    let next = current.nextElementSibling;
    let previous = current.previousElementSibling;
    if (next != null) {
      obj.setSelectedQuestion(next.dataset.question_id);
    } else if (previous != null) {
      obj.setSelectedQuestion(previous.dataset.question_id);
    }
  };

  obj.setSelectedQuestion = function (id) {
    previously_selected_id = currently_selected_id;
    currently_selected_id = id;
    Data.setQuestion(csrf, quiz_id, id);
    let previous = getRow(previously_selected_id);
    if (previous != null) {
      previous.classList.remove('active_question');
    }
    getRow(id).classList.add('active_question');
  };

  obj.removeRow = function (question_id) {
    let row = getRow(question_id);
    row.remove();
  };

  obj.addRow = function (question) {
    question_table.render();
    // let row = document.createElement('tr');
    // row.classList.add('list_row');
    // row.dataset.question_id = question.id;
    // // create elements
    // let content = document.createElement('td');
    // let current_streak = document.createElement('td');
    // let longest_streak = document.createElement('td');
    // // set values
    // content.textContent = question.content;
    // current_streak.textContent = '0';
    // longest_streak.textContent = '0';
    // //
    // row.onclick = (event) => {
    //   obj.setSelectedQuestion(event.currentTarget.dataset.question_id);
    // };
    // // add to dom
    // row.appendChild(content);
    // row.appendChild(current_streak);
    // row.appendChild(longest_streak);
    // question_table.appendChild(row);
  };

  question_table.render();
  return obj;
}
