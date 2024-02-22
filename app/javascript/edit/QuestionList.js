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
    next = next === null ? null : next.firstChild;
    let previous = current.previousElementSibling;
    previous = previous === null ? null : previous.firstChild;
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
    let row = getRow(id);
    row.classList.add('active_question');
  };

  obj.refresh = function () {
    question_table.forceRender();
  };

  question_table.render();
  return obj;
}
