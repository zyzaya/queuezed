export default function QuestionList(csrf, quiz_id) {
  let obj = {};
  let question_table =
    document.getElementById('question_list').firstElementChild;
  let previously_selected_id = null;
  let currently_selected_id = null;

  let rows = document.getElementsByClassName('list_row');
  for (let i = 0; i < rows.length; i++) {
    rows[i].onclick = (event) => {
      obj.setSelectedQuestion(event.currentTarget.dataset.question_id);
    };
  }

  let getRow = function (id) {
    return document.querySelector(`.list_row[data-question_id="${id}"]`);
  };

  // public functions
  obj.getCurrentlySelectedID = () => currently_selected_id;
  obj.getPreviouslySelectedID = () => previously_selected_id;

  obj.setSelectedToSibling = function () {
    let current = getRow(currently_selected_id);
    let next = current.nextElementSibling;
    let previous = current.nextElementSibling;
    if (next != null) {
      obj.setSelectedQuestion(next.dataset.question_id);
    } else if (previous != null) {
      obj.setSelectedQuestion(previous.dataset.question_id);
    }
  };

  obj.setSelectedQuestion = function (id) {
    previously_selected_id = currently_selected_id;
    currently_selected_id = id;
    // get question data
    fetch(`/quizzes/${quiz_id}/update`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
    }).then(() => {
      Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${id}/edit`, {
        frame: 'edit_detail',
        action: 'replace',
      });
    });
    // change visual selection
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
    let row = document.createElement('tr');
    row.classList.add('list_row');
    row.dataset.question_id = question.id;
    // create elements
    let content = document.createElement('td');
    let current_streak = document.createElement('td');
    let longest_streak = document.createElement('td');
    // set values
    content.textContent = question.content;
    current_streak.textContent = '0';
    longest_streak.textContent = '0';
    // add to dom
    row.appendChild(content);
    row.appendChild(current_streak);
    row.appendChild(longest_streak);
    // row.onclick = () => setSelectedQuestion(question.id);
    question_table.appendChild(row);
  };

  return obj;
}
