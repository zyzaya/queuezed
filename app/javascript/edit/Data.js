const Data = (() => {
  let save = function (csrf, quiz_id, changes) {
    console.log(changes);
    fetch(`/quizzes/${quiz_id}/update`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
      body: JSON.stringify(changes),
    });
  };

  let newQuestion = function (csrf, quiz_id) {};

  let deleteQuestion = function (csrf, quiz_id, question_id) {
    fetch(`/quizzes/${quiz_id}/edit/questions/${question_id}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
    });
  };

  return { save, newQuestion, deleteQuestion };
})();

export default Data;
