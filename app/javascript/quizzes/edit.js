console.log('yes this this working');

// add click evenet to every list row
let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
let changes = { a: '' };
let quiz_id = document.getElementsByClassName('quizzes_edit')[0].id;
let rows = document.getElementsByClassName('list_row');
let detail_frame = document.getElementById('edit_detail');
let previous_id = null;
let current_id = null;

function setQuestion(id) {
  previous_id = current_id;
  current_id = id;
  fetch(`/quizzes/${quiz_id}/update`, {
    method: 'POST',
    body: JSON.stringify(changes),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrf,
    },
    credentials: 'same-origin',
  }).then(() => {
    Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${current_id}/edit`, {
      frame: 'edit_detail',
      action: 'replace',
    });
  });
}

// table row click
for (let i = 0; i < rows.length; i++) {
  rows[i].onclick = () => {
    setQuestion(rows[i].id);
  };
}

// question focus
detail_frame.addEventListener('turbo:frame-render', (event) => {
  if (previous_id != null) {
    document.getElementById(previous_id).classList.remove('active_question');
  }
  document.getElementById(current_id).classList.add('active_question');
});

// new question
let question_table = document.getElementById('question_list').firstElementChild;
function addRow(question) {
  let row = document.createElement('tr');
  row.classList.add('list_row');
  row.id = question.id;
  let content = document.createElement('td');
  let current_streak = document.createElement('td');
  current_streak.textContent = '0';
  let longest_streak = document.createElement('td');
  longest_streak.textContent = '0';

  row.appendChild(content);
  row.appendChild(current_streak);
  row.appendChild(longest_streak);
  row.onclick = () => setQuestion(question.id);
  question_table.appendChild(row);
}

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
      addRow(question);
    });
};

/* 
  apply local changes client side

  first load: local changes ->
    quiz = {}
  make changes: local changes ->
    quiz = {stuff}
  load new question:
   retrieve data from server
   apply local changes to display
  save changes:
   send changes to server
*/
// OR
/*
  apply local changes server side/////

  first load: local changes ->
    quiz = {}
  make changes: local changes ->
    quiz = {stuff}
  load new question:
    send local changes to server
    retrieve new question data
*/
