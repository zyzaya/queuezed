console.log('yes this this working');

// add click evenet to every list row
let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
let changes = { a: '' };
let quiz_id = document.getElementsByClassName('quizzes_edit')[0].id;
let rows = document.getElementsByClassName('list_row');
let detail_frame = document.getElementById('edit_detail');
let previous_id = null;
let current_id = null;

// table row click
for (let i = 0; i < rows.length; i++) {
  rows[i].onclick = () => {
    previous_id = current_id;
    current_id = rows[i].id;
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
let new_question = document.getElementById('new_question');
new_question.onclick = (e) => {
  console.log('new question');
  Turbo.visit(`/quizzes/${quiz_id}/edit/questions/new`, {
    frame: 'edit_detail',
    action: 'replace',
  });
  // add table row
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
