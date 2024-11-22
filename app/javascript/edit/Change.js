import Data from 'edit/Data';

export default class Change {
  // questions, as retrieved from the server with
  // all local modifications applied
  static #questions = [];

  // all local modifications, in the format accepted
  // by a post request to the server
  static #changes = {
    questions: [],
  };

  static LoadQuestions(quiz_id) {
    this.Reset();
    return Data.getQuestions(quiz_id).then((q) => (this.#questions = q));
  }

  static GetQuestion(id) {
    return this.#questions.find((q) => q.id == id);
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

  static #getRelationChanges(question, relation_id) {
    let relation = undefined;
    if (question.relations == undefined) {
      question.relations = [];
    } else {
      relation = question.relations.find((e) => e.id == relation_id);
    }
    if (relation === undefined) {
      relation = { id: relation_id };
      question.relations.push(relation);
    }
    return relation;
  }

  static #addRelation(id_1, id_2) {
    let q = this.GetQuestion(id_1);
    if (q.relations === undefined) q.relations = [];
    let r = { id: id_2 };
    if (q.relations.find((e) => e.id == id_2) == undefined) {
      q.relations.push(r);
    }

    let question = this.#getQuestionChanges(id_1);
    let relation = this.#getRelationChanges(question, id_2);

    relation.meta = relation.meta === 'delete' ? '' : 'add';
  }

  static AddRelated(question_id, relation_id) {
    this.#addRelation(question_id, relation_id);
    this.#addRelation(relation_id, question_id);
  }

  static #removeRelation(id_1, id_2) {
    let q = this.GetQuestion(id_1);
    q.relations = q.relations.filter((r) => r.id != id_2);

    let question = this.#getQuestionChanges(id_1);
    let relation = this.#getRelationChanges(question, id_2);
    if (relation.meta === 'add') {
      question.relations = question.relations.filter((e) => e.id != id_2);
    } else {
      relation.meta = 'delete';
    }
  }

  static RemoveRelated(question_id, relation_id) {
    this.#removeRelation(question_id, relation_id);
    this.#removeRelation(relation_id, question_id);
  }

  static AddAnswer(question_id, answer_id, index = -1) {
    let q = this.GetQuestion(question_id);
    if (q.answers === undefined) q.answers = [];
    let a = { id: answer_id, content: '' };
    if (q.answers.find((e) => e.id == answer_id) == undefined) {
      if (index === -1) q.answers.push(a);
      else q.answers.splice(index, 0, a);
    }

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

  static AddQuestion(id, data) {
    let q = this.GetQuestion(id);
    if (q !== undefined) {
      console.error(`Question with id ${id} already exists`);
      return;
    }

    if (data !== undefined) {
      q = data;
    } else {
      q = {
        answers: [],
        content: '',
        current_streak: 0,
        difficult: false,
        id: id,
        last_taken: null,
        longest_streak: 0,
        next_review: '',
        rank: 0,
        relations: [],
        review: false,
        tags: [],
        times_taken: 0,
        times_correct: 0,
      };
    }
    this.#questions.push(q);

    let question = this.#getQuestionChanges(id);
    if (question.meta === 'delete') {
      this.#changes.questions = this.#changes.questions.filter(
        (e) => e.id != question.id
      );
      data.relations.forEach((r) => {
        let other = this.GetQuestion(r.id);
        other.relations.push({ id: data.id });
      });
    } else {
      question.meta = 'new';
      if (data !== undefined) {
        question.content = data.content;
        data.answers.forEach((a) => {
          this.AddAnswer(question.id, a.id);
          this.SetAnswerContent(question.id, a.id, a.content);
        });
        data.tags.forEach((t) => this.AddTag(question.id, t.id, t.content));
        data.relations.forEach((r) => this.AddRelated(question.id, r.id));
      }
    }
  }

  static DeleteQuestion(id) {
    let q = this.GetQuestion(id);
    this.#questions = this.#questions.filter((e) => e.id != id);
    this.#questions.forEach((q) => {
      q.relations = q.relations.filter((r) => r.id != id);
    });

    let question = this.#getQuestionChanges(id);
    if (question.meta === 'new') {
      this.#changes.questions = this.#changes.questions.filter(
        (e) => e.id != id
      );
    } else {
      question.meta = 'delete';
    }
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
    if (q.tags.find((e) => e.id == tag_id) == undefined)
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
    if (q.tags.find((e) => e.id == tag_id) == undefined)
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
    if (tag.meta === 'add' || tag.meta === 'new') {
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
      question.tags = question.tags.filter((e) => e.id != tag_id);
    } else {
      tag.meta = 'delete';
    }
  }

  static #parseId(id) {
    let parsed = parseInt(id);
    return parsed === NaN ? id : parsed;
  }

  static #parseIds() {
    this.#changes.questions?.forEach((q) => {
      q.id = this.#parseId(q.id);
      q.answers?.forEach((a) => (a.id = this.#parseId(a.id)));
      q.tags?.forEach((t) => (t.id = this.#parseId(t.id)));
      q.relations?.forEach((r) => (r.id = this.#parseId(r.id)));
    });
  }

  static GetChanges(idConversion = null) {
    this.#parseIds();
    if (idConversion === null) return this.#changes;

    for (const [temp, real] of Object.entries(idConversion.questions)) {
      this.#changes.questions.forEach((q) => {
        if (q.id == temp) q.id = real;
      });
    }

    for (const [temp, real] of Object.entries(idConversion.answers)) {
      this.#changes.questions.forEach((q) => {
        if (q.answers != null) {
          q.answers.forEach((a) => {
            if (a.id == temp) a.id = real;
          });
        }
      });
    }

    for (const [temp, real] of Object.entries(idConversion.tags)) {
      this.#changes.questions.forEach((q) => {
        if (q.tags != null) {
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
