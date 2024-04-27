import { Controller } from '@hotwired/stimulus';
import Data from 'edit/Data';

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
    this.dispatch('new');
  }

  save() {
    console.log('save');
  }
}
