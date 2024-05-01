import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    quizId: String,
  };

  static targets = ['title'];

  initialize() {
    this.previous_title = '';
    this.current_title = this.titleTarget.value;
  }

  quizTitleChange(event) {
    this.previous_title = this.current_title;
    this.current_title = this.titleTarget.value;
    this.dispatch('quizTitleChange', {
      detail: {
        current: this.current_title,
        previous: this.previous_title,
        input: this.titleTarget,
      },
    });
  }
}
