import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['info'];

  static values = {
    questionId: String,
  };

  initialize() {
    this.previous = '';
    this.current = this.infoTarget.value;
  }

  questionContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    this.dispatch('questionContentChange', {
      detail: {
        questionId: this.questionIdValue,
        current: this.current,
        previous: this.previous,
        textarea: this.infoTarget,
      },
    });
  }
}
