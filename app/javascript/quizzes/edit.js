console.log('yes this this working');

// add click evenet to every list row
let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
let changes = { a: '' };
let quiz_id = document.getElementsByClassName('quizzes_edit')[0].id;
let rows = document.getElementsByClassName('list_row');
let detail_frame = document.getElementById('edit_detail');

function setDetails(info) {}

for (let i = 0; i < rows.length; i++) {
  rows[i].onclick = () => {
    console.log(`hi ${rows[i].id}`);
    let q_id = rows[i].id;
    fetch(`/quizzes/${quiz_id}/update`, {
      method: 'POST',
      body: JSON.stringify(changes),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
    }).then(() => {
      Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${q_id}`, {
        frame: 'edit_detail',
        action: 'replace',
      });
    });
  };
}

detail_frame.addEventListener('turbo:frame-render', (event) => {
  console.log(event.detail.fetchResponse);
});

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
