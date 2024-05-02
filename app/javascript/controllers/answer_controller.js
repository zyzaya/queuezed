import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['info'];
  static outlets = ['single-question'];

  static values = {
    id: String,
    questionId: String,
  };

  initialize() {
    this.previous = '';
    this.current = this.infoTarget.value;
  }

  connect() {
    this.dispatch('load', {
      detail: {
        questionId: this.questionIdValue,
        answerId: this.idValue,
        textarea: this.infoTarget,
      },
    });
  }

  answerContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    this.dispatch('answerContentChange', {
      detail: {
        questionId: this.questionIdValue,
        answerId: this.idValue,
        current: this.current,
        previous: this.previous,
        textarea: this.infoTarget,
      },
    });
  }

  delete(event) {
    this.dispatch('delete', {
      detail: {
        questionId: this.questionIdValue,
        answerId: this.idValue,
        current: this.current,
        parent: this.singleQuestionOutletElement,
      },
    });
  }
}
