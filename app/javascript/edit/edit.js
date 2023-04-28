import QuestionList from 'edit/QuestionList';

console.log('yes this this working');

// add click evenet to every list row
let csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
// .list_row[data-question_id]
let question_table = document.getElementById('question_list').firstElementChild;
let changes = { a: '' };
let quiz_id = document.getElementById('quizzes_edit').dataset.quiz_id;
console.log(quiz_id);
let rows = document.getElementsByClassName('list_row');
let detail_frame = document.getElementById('edit_detail');
let previous_id = null;
let current_id = null;

let question_list = QuestionList(csrf, quiz_id);

function setSelectedQuestion(id) {
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

function deleteQuestion(id) {
  // server delete
  fetch(`/quizzes/${quiz_id}/edit/questions/${current_id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrf,
    },
    credentials: 'same-origin',
  });
  //
  // set question to sibling id
  // let current = document.getElementById(current_id);
  let current = document.querySelector(
    `.list_row[data-question_id=${current_id}]`
  );
  let next = current.nextElementSibling;
  let previous = current.previousElementSibling;
  if (next != null) {
    setSelectedQuestion(next.id);
  } else if (previous != null) {
    setSelectedQuestion(previous.id);
  } else {
    // clearSelectedQuestion()
  }
  question_list.removeRow(previous_id);
}

// table row click
for (let i = 0; i < rows.length; i++) {
  rows[i].onclick = (event) => {
    setSelectedQuestion(event.currentTarget.dataset.question_id);
  };
}

// question focus
detail_frame.addEventListener('turbo:frame-render', (event) => {
  let previous = document.querySelector(
    `.list_row[data-question_id="${previous_id}"]`
  );
  if (previous != null) {
    previous.classList.remove('active_question');
  }
  console.log(current_id);
  document
    .querySelector(`.list_row[data-question_id="${current_id}"]`)
    .classList.add('active_question');
  document.getElementById('delete_question').onclick = () => {
    deleteQuestion(current_id);
  };
});

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
      question_list.addRow(question);
    });
};
