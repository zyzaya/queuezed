console.log('yes this this working');

// add click evenet to every list row

let quiz_id = document.getElementsByClassName('quizzes_edit')[0].id;

let rows = document.getElementsByClassName('list_row');

for (let i = 0; i < rows.length; i++) {
  rows[i].onclick = () => {
    console.log(`hi ${rows[i].id}`);
    let q_id = rows[i].id;
    Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${q_id}`, {
      frame: 'edit_detail',
      action: 'replace',
    });
  };
}
