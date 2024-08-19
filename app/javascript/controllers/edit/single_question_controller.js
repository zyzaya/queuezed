import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['info'];

  static values = {
    id: String,
  };

  initialize() {
    this.previous = '';
    this.current = this.infoTarget.value;
  }

  connect() {
    this.dispatch('load', {
      detail: {
        parent: this.element,
        questionId: this.idValue,
        textarea: this.infoTarget,
      },
    });
  }

  questionContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    this.dispatch('questionContentChange', {
      detail: {
        questionId: this.idValue,
        current: this.current,
        previous: this.previous,
        textarea: this.infoTarget,
      },
    });
  }

  addAnswer(event) {
    this.dispatch('addAnswer', {
      detail: {
        parent: this.element,
        questionId: this.idValue,
      },
    });
  }
}
