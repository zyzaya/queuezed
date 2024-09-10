export default class Change {
  static #changes = {
    questions: [],
  };

  static SetQuizName(name) {
    this.#changes.name = name;
  }

  static #getTag(question_id, tag_id, content) {
    let question = this.#getQuestion(question_id);
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
  }

  static #getQuestion(id) {
    let question = this.#changes.questions.find((e) => e.id === id);
    if (question === undefined) {
      question = { id: id };
      this.#changes.questions.push(question);
    }
    return question;
  }

  static #getAnswer(question, answer_id) {
    let answer = undefined;
    if (question.answers == undefined) {
      question.answers = [];
    } else {
      answer = question.answers.find((e) => e.id == answer_id);
    }
    if (answer === undefined) {
      answer = { id: answer_id };
      question.answers.push(answer);
    }
    return answer;
  }

  static AddAnswer(question_id, answer_id) {
    let question = this.#getQuestion(question_id);
    let answer = this.#getAnswer(question, answer_id);
    answer.meta = answer.meta === 'delete' ? '' : 'new';
  }
  static DeleteAnswer(question_id, answer_id) {
    let question = this.#getQuestion(question_id);
    let answer = this.#getAnswer(question, answer_id);
    if (answer.meta === 'new') {
      question.answers = question.answers.filter((e) => e.id !== answer_id);
    } else {
      answer.meta = 'delete';
    }
  }
  static SetAnswerContent(question_id, answer_id, content) {
    let question = this.#getQuestion(question_id);
    let answer = this.#getAnswer(question, answer_id);
    answer.content = content;
  }

  static AddQuestion(question_id) {
    console.error('Change.AddQuestion not implemented');
  }
  static DeleteQuetion(question_id) {
    console.error('Change.DeleteQuestion not implemented');
  }
  static SetQuestionContent(question_id, content) {
    let question = this.#getQuestion(question_id);
    question.content = content;
  }

  static AddTag(question_id, tag_id, content) {
    let question = this.#getQuestion(question_id);
    let tag = this.#getTag(question_id, tag_id, content);
    if (tag.meta === 'remove') {
      question.tags = question.tags.filter(
        (e) => !(e.id === tag_id && e.content === content)
      );
    } else {
      tag.meta = 'add';
    }
  }
  static CreateTag(question_id, tag_id, content) {
    let question = this.#getQuestion(question_id);
    let tag = this.#getTag(question_id, tag_id, content);
    if (tag.meta === 'delete') {
      question.tags = question.tags.filter((e) => e !== tag);
    } else {
      tag.meta = 'new';
    }
  }
  static RemoveTag(question_id, tag_id, content) {
    let question = this.#getQuestion(question_id);
    let tag = this.#getTag(question_id, tag_id, content);
    if (tag.meta === 'add') {
      question.tags = question.tags.filter(
        (e) => !(e.id === tag_id && e.content === content)
      );
    } else {
      tag.meta = 'remove';
    }
  }
  static DeleteTag(question_id, tag_id, content) {
    let question = this.#getQuestion(question_id);
    let tag = this.#getTag(question_id, tag_id, content);
    if (tag.meta === 'new') {
      question.tags = question.tags.filter((e) => e !== tag);
    } else {
      tag.meta = 'delete';
    }
  }

  static GetChanges(idConversion = null) {
    if (idConversion === null) return this.#changes;

    for (const [temp, real] of Object.entries(idConversion.answers)) {
      this.#changes.questions.forEach((q) => {
        if (q.answers !== null) {
          q.answers.forEach((a) => {
            if (a.id === temp) a.id = real;
          });
        }
      });
    }

    for (const [temp, real] of Object.entries(idConversion.tags)) {
      this.#changes.questions.forEach((q) => {
        if (q.tags !== null) {
          q.tags.forEach((t) => {
            if (t.id === temp) t.id = real;
          });
        }
      });
    }

    return this.#changes;
  }

  static Reset() {
    this.#changes = {
      questions: [],
    };
  }
}
