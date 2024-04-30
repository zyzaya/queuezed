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

  answerContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    this.dispatch('answerContentChange', {
      detail: {
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
        answerId: this.idValue,
      },
    });
  }
}
