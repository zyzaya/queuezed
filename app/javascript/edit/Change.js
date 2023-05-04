export default function Change(csrf, quiz_id) {
  let obj = {};
  let changes = {
    questions: [],
  };
  let undo_stack = {};

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
    return answer;
  };

  obj.addAnswer = function (question_id, answer_id) {
    // add to changes
    let question = getQuestion(question_id);
    if (question.answers == undefined) question.answers = [];
    let answer = { meta: 'new', id: answer_id };
    question.answers.push(answer);
    console.log(changes);
  };

  obj.deleteAnswer = function (question_id, answer_id) {
    let question = getQuestion(question_id);
    let answer = getAnswer(question, answer_id);
    if (answer == undefined) {
      answer = { id: answer_id };
      question.answers.push(answer);
    }
    answer.meta = 'delete';
    console.log(changes);
  };

  return obj;
}
