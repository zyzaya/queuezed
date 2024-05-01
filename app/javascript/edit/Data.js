const Data = (() => {
  let setQuestion = function (csrf, quiz_id, question_id) {
    Turbo.visit(`/quizzes/${quiz_id}/edit/questions/${question_id}/edit`, {
      frame: 'edit_detail',
      action: 'replace',
    });
  };

  let save = function (csrf, quiz_id, changes) {
    console.log(changes);
    console.log(quiz_id);
    return fetch(`/quizzes/${quiz_id}/update`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
      body: JSON.stringify(changes),
    });
  };

  let newQuestion = function (csrf, quiz_id) {
    return fetch(`/quizzes/${quiz_id}/edit/questions/new`)
      .then((response) => response.json())
      .then((question) => {
        setQuestion(csrf, quiz_id, question.id);
        return question;
      });
  };

  let deleteQuestion = function (csrf, quiz_id, question_id) {
    return fetch(`/quizzes/${quiz_id}/edit/questions/${question_id}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
    });
  };

  let restoreQuestion = function (csrf, quiz_id, question_id) {
    return fetch(`/quizzes/${quiz_id}/edit/questions/${question_id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
      body: JSON.stringify({ restore: true }),
    });
  };

  let getQuestions = function (quiz_id) {
    return fetch(`/quizzes/${quiz_id}/questions`).then((response) =>
      response.json()
    );
  };

  return {
    save,
    newQuestion,
    deleteQuestion,
    restoreQuestion,
    setQuestion,
    getQuestions,
  };
})();

export default Data;
