export default function Change(csrf, quiz_id) {
  let obj = {};
  let changes = {
    questions: [],
  };

  obj.setQuizTitle = function (title) {
    changes.quiz_title = title;
  };
  // answers
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

  obj.addAnswer = function (question_id, answer_id) {
    let question = getQuestion(question_id);
    let answer = getAnswer(question, answer_id);
    if (answer.meta === 'delete') {
      answer.meta = '';
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
  // questions
  let getQuestion = function (question_id) {
    let question = changes.questions.find((e) => e.id == question_id);
    if (question === undefined) {
      question = { id: question_id };
      changes.questions.push(question);
    }
    return question;
  };

  obj.setQuestionContent = function (question_id, content) {
    let question = getQuestion(question_id);
    question.content = content;
  };
  // tags
  let getTag = function (question_id, tag_id, content) {
    let question = getQuestion(question_id);
    if (question.tags === undefined) question.tags = [];
    let tag = question.tags.find(
      (t) => t.id === tag_id && t.content === content
    );
    if (tag === undefined) {
      tag = {
        id: tag_id,
        content: content,
      };
      question.tags.push(tag);
    }
    return tag;
  };

  obj.addTag = function (question_id, tag_id, content) {
    let question = getQuestion(question_id);
    let tag = getTag(question_id, tag_id, content);
    if (tag.meta === 'remove') {
      question.tags = question.tags.filter(
        (e) => !(e.id === tag_id && e.content === content)
      );
    } else {
      tag.meta = 'add';
    }
  };

  obj.removeTag = function (question_id, tag_id, content) {
    let question = getQuestion(question_id);
    let tag = getTag(question_id, tag_id, content);
    if (tag.meta === 'add') {
      question.tags = question.tags.filter(
        (e) => !(e.id === tag_id && e.content === content)
      );
    } else {
      tag.meta = 'remove';
    }
  };

  //
  obj.getChanges = () => changes;
  obj.resetChanges = () => (changes = { questions: [] });

  return obj;
}
