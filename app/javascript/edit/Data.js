const Data = (() => {
  let edit_question_path = (id) => `/questions/${id}/edit`;
  let quiz_path = (id) => `/quizzes/${id}`;
  let quiz_questions_path = (quiz_id) => `/quizzes/${quiz_id}/questions`;
  let new_quiz_question_path = (quiz_id) => `/quizzes/${quiz_id}/questions/new`;
  let question_path = (id) => `/questions/${id}`;

  let save = function (csrf, quiz_id, changes) {
    return fetch(quiz_path(quiz_id), {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
      },
      credentials: 'same-origin',
      body: JSON.stringify({ quiz: changes }),
    });
  };

  let getQuestions = function (quiz_id) {
    return fetch(quiz_questions_path(quiz_id)).then((response) =>
      response.json()
    );
  };

  return {
    save,
    getQuestions,
  };
})();

export default Data;
