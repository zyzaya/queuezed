export default function Change(csrf, quiz_id) {
  let obj = {};
  let changes = {
    questions: [],
  };

  let getQuestion = function (question_id) {
    let question = changes.questions.find((e) => e.id == question_id);
    if (question == undefined) {
      question = { id: question_id };
      changes.questions.push(question);
    }
    return question;
  };

  let getAnswer = function (question, answer_id) {
    let answer = undefined;
    if (question.answers == undefined) {
      question.answers = [];
    } else {
      answer = question.answers.find((e) => e.id == answer_id);
    }
    if (answer == undefined) {
      answer = { id: answer_id };
      question.answers.push(answer);
    }
    return answer;
  };

  obj.setQuestionContent = function (question_id, content) {
    let question = getQuestion(question_id);
    question.content = content;
  };

  obj.addAnswer = function (question_id, answer_id) {
    let question = getQuestion(question_id);
    let answer = getAnswer(question, answer_id);
    if (answer.meta === 'delete') {
      question.answers = question.answers.filter((e) => e.id !== answer_id);
    } else {
      answer.meta = 'new';
    }
  };

  obj.deleteAnswer = function (question_id, answer_id) {
    let question = getQuestion(question_id);
    let answer = getAnswer(question, answer_id);

    if (answer.meta === 'new') {
      question.answers = question.answers.filter((e) => e.id !== answer_id);
    } else {
      answer.meta = 'delete';
    }
  };

  obj.setAnswerContent = function (question_id, answer_id, content) {
    let question = getQuestion(question_id);
    let answer = getAnswer(question, answer_id);
    answer.content = content;
  };

  obj.getChanges = () => changes;

  return obj;
}
