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

  questionContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    this.dispatch('contentChange', {
      detail: {
        id: this.idValue,
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

  setContent(event) {
    if (this.idValue === event.detail.id) {
      this.infoTarget.value = event.detail.content;
    }
  }
}
