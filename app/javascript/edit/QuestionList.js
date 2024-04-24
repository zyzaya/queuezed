import Data from 'edit/Data';
import { zGrid } from 'zGrid';

export default function QuestionList(csrf, quiz_id) {
  let obj = {};

  let onClick = function (col, row, col_name, data) {
    obj.setSelectedQuestion(data['id']);
  };

  let question_table = new zGrid({
    parent: document.getElementById('gridjs'),
    data: [],
    columns: [
      {
        id: 'id',
        visible: true,
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
    className: {
      tbody: 'zgrid_body',
      tr: 'zgrid_tr',
    },
  });

  let previously_selected_id = null;
  let currently_selected_id = null;

  let convertQuestionIDToRowIndex = function (id) {
    let row_index = question_table.getData().findIndex((e) => e.id === id);
    return row_index;
  };

  let getRow = function (id) {
    let body = document.getElementsByClassName('zgrid_body');
    if (body.length !== 1) return null;
    body = body[0];
    let row_index = convertQuestionIDToRowIndex(id);
    if (body === null || row_index === -1) return null;
    let row = body.children[row_index];

    return row;
  };

  // public functions
  obj.getCurrentlySelectedID = () => currently_selected_id;
  obj.getPreviouslySelectedID = () => previously_selected_id;

  obj.setSelectedToSibling = function () {
    let data = question_table.getData();
    let current = data.findIndex((e) => e.id === currently_selected_id);
    if (current === -1) return;
    if (current + 1 < data.length) {
      let sibling = data[current + 1];
      obj.setSelectedQuestion(sibling['id']);
    } else if (current - 1 >= 0) {
      let sibling = data[current - 1];
      obj.setSelectedQuestion(sibling['id']);
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
    return Data.getQuestions(quiz_id).then((questions) => {
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
