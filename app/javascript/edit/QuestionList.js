/*
  set selected question
  delete question
    remove row
  new question
    addrow
*/

export default function QuestionList(csrf, quiz_id) {
  let obj = {};
  let question_table =
    document.getElementById('question_list').firstElementChild;

  obj.removeRow = function (question_id) {
    let row = document.getElementById(question_id);
    row.remove();
  };

  obj.addRow = function (question) {
    let row = document.createElement('tr');
    row.classList.add('list_row');
    row.id = question.id;
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
