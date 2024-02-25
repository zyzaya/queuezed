import Data from 'edit/Data';
import { zGrid } from 'zGrid';

export default function QuestionList(csrf, quiz_id) {
  let obj = {};

  let onClick = function (col, row, col_name, data) {
    console.log(`${col}, ${row}, ${col_name}`);
    console.log(data);
  };

  let question_table = new zGrid({
    parent: document.getElementById('gridjs'),
    data: [],
    columns: [
      {
        id: 'id',
        visible: false,
      },
      {
        id: 'content',
        name: 'Question',
      },
      {
        id: 'current_streak',
        name: 'Streak',
      },
      {
        id: 'longest_streak',
        name: 'Best Streak',
      },
    ],
    onClick: onClick,
  });

  let previously_selected_id = null;
  let currently_selected_id = null;

  // question_table.onClick = function (event, data) {
  //   obj.setSelectedQuestion(data.cells[0].data);
  // };

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
    Data.getQuestions(quiz_id).then((questions) => {
      console.log(questions);
      let data = questions.map((e) => {
        return {
          id: e.id.toString(),
          content: e.content,
          current_streak: e.current_streak,
          longest_streak: e.longest_streak,
        };
      });
      question_table.reconfigure({
        data: data,
      });
    });
  };

  obj.refresh();
  return obj;
}
