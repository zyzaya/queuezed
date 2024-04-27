import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    quizId: String,
  };

  initialize() {
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
  }

  connect() {
    console.log('hello');
  }

  undo() {
    console.log('undo');
  }

  redo() {
    console.log('redo');
  }

  newQuestion() {
    // data.new question
    // set selected q to new question
  }

  save() {
    console.log('save');
  }
}
