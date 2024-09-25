import Data from 'edit/Data';

export default class Change {
  static #questions = [];

  static #changes = {
    questions: [],
  };

  static LoadQuestions(quiz_id) {
    this.Reset();
    return Data.getQuestions(quiz_id).then((q) => (this.#questions = q));
  }

  static GetQuestion(id) {
    return this.#questions.find((q) => q.id === parseInt(id));
  }

  static #getAnswer(question_id, answer_id) {
    let question = this.GetQuestion(question_id);
    if (question.answers === undefined) return undefined;
    return question.answers.find((a) => a.id == answer_id);
  }

  static #getTag(question_id, tag_id) {
    let question = this.GetQuestion(question_id);
    if (question.tags === undefined) return undefined;
    return question.tags.find((t) => t.id == tag_id);
  }

  static SetQuizName(name) {
    this.#changes.name = name;
  }

  static #getTagChanges(question_id, tag_id, content) {
    let question = this.#getQuestionChanges(question_id);
    if (question.tags === undefined) question.tags = [];
    let tag = question.tags.find(
      (t) => t.id == tag_id && t.content === content
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

  static #getQuestionChanges(id) {
    let question = this.#changes.questions.find((e) => e.id == id);
    if (question === undefined) {
      question = { id: id };
      this.#changes.questions.push(question);
    }
    return question;
  }

  static #getAnswerChanges(question, answer_id) {
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
    let q = this.GetQuestion(question_id);
    if (q.answers === undefined) q.answers = [];
    q.answers.push({ id: answer_id, content: '' });

    let question = this.#getQuestionChanges(question_id);
    let answer = this.#getAnswerChanges(question, answer_id);

    answer.meta = answer.meta === 'delete' ? '' : 'new';
  }

  static DeleteAnswer(question_id, answer_id) {
    let q = this.GetQuestion(question_id);
    q.answers = q.answers.filter((a) => a.id != answer_id);

    let question = this.#getQuestionChanges(question_id);
    let answer = this.#getAnswerChanges(question, answer_id);
    if (answer.meta === 'new') {
      question.answers = question.answers.filter((e) => e.id != answer_id);
    } else {
      answer.meta = 'delete';
    }
  }

  static SetAnswerContent(question_id, answer_id, content) {
    let q = this.GetQuestion(question_id);
    let a = q.answers.find((a) => a.id == answer_id);
    a.content = content;

    let question = this.#getQuestionChanges(question_id);
    let answer = this.#getAnswerChanges(question, answer_id);
    answer.content = content;
  }

  static AddQuestion(question_id) {
    console.error('Change.AddQuestion not implemented');
  }

  static DeleteQuetion(question_id) {
    console.error('Change.DeleteQuestion not implemented');
  }

  static SetQuestionContent(question_id, content) {
    let q = this.GetQuestion(question_id);
    q.content = content;

    let question = this.#getQuestionChanges(question_id);
    question.content = content;
  }

  static AddTag(question_id, tag_id, content) {
    let q = this.GetQuestion(question_id);
    if (q.tags === undefined) q.tags = [];
    q.tags.push({ id: tag_id, content: content });

    let question = this.#getQuestionChanges(question_id);
    let tag = this.#getTagChanges(question_id, tag_id, content);
    if (tag.meta === 'remove') {
      question.tags = question.tags.filter(
        (e) => !(e.id == tag_id && e.content === content)
      );
    } else {
      tag.meta = 'add';
    }
  }

  static CreateTag(question_id, tag_id, content) {
    let q = this.GetQuestion(question_id);
    if (q.tags === undefined) q.tags = [];
    q.tags.push({ id: tag_id, content: content });

    let question = this.#getQuestionChanges(question_id);
    let tag = this.#getTagChanges(question_id, tag_id, content);
    if (tag.meta === 'delete') {
      question.tags = question.tags.filter((e) => e.id != tag.id);
    } else {
      tag.meta = 'new';
    }
  }

  static RemoveTag(question_id, tag_id, content) {
    let q = this.GetQuestion(question_id);
    q.tags = q.tags.filter((t) => t.id != tag_id);

    let question = this.#getQuestionChanges(question_id);
    let tag = this.#getTagChanges(question_id, tag_id, content);
    if (tag.meta === 'add') {
      question.tags = question.tags.filter(
        (e) => !(e.id == tag_id && e.content === content)
      );
    } else {
      tag.meta = 'remove';
    }
  }

  static DeleteTag(question_id, tag_id, content) {
    let q = this.GetQuestion(question_id);
    q.tags = q.tags.filter((t) => t.id != tag_id);

    let question = this.#getQuestionChanges(question_id);
    let tag = this.#getTagChanges(question_id, tag_id, content);
    if (tag.meta === 'new') {
      question.tags = question.tags.filter((e) => e != tag);
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
            if (a.id == temp) a.id = real;
          });
        }
      });
    }

    for (const [temp, real] of Object.entries(idConversion.tags)) {
      this.#changes.questions.forEach((q) => {
        if (q.tags !== null) {
          q.tags.forEach((t) => {
            if (t.id == temp) t.id = real;
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
