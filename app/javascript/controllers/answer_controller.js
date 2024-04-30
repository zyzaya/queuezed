import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['info'];

  static values = {
    answerId: String,
  };

  initialize() {
    this.previous = '';
    this.current = this.infoTarget.value;
    // this.infoValue = this.infoTarget.value;
  }

  answerContentChange(event) {
    this.previous = this.current;
    this.current = this.infoTarget.value;
    console.log(`p: ${this.previous}\nc: ${this.current}`);
    this.dispatch('answerContentChange', {
      detail: {
        current: this.current,
        previous: this.previous,
        textarea: this.infoTarget,
      },
    });
  }

  infoValueChanged(current, previous) {}
}
