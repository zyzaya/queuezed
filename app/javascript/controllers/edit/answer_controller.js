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

  answerContentChange(event) {
    let content = this.infoTarget.value;

    this.previous = this.current;
    this.current = content;
    this.dispatch('contentChange', {
      detail: {
        question_id: this.questionIdValue,
        answer_id: this.idValue,
        current: this.current,
        previous: this.previous,
      },
    });
  }

  delete(event) {
    this.dispatch('delete', {
      detail: {
        question_id: this.questionIdValue,
        answer_id: this.idValue,
        current: this.current,
        parent: this.editSingleQuestionOutletElement,
      },
    });
  }
}
