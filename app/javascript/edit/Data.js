const Data = (() => {
  let edit_question_path = (id) => `/questions/${id}/edit`;
  let quiz_path = (id) => `/quizzes/${id}`;

  let setQuestion = function (csrf, quiz_id, question_id) {
    Turbo.visit(edit_question_path(question_id), {
      frame: 'edit_detail',
      action: 'replace',
    });
  };

  let save = function (csrf, quiz_id, changes) {
    return fetch(`/quizzes/${quiz_id}/update`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
      body: JSON.stringify(changes),
    }).then((response) => response.json());
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
