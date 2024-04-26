import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
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
    console.log('newQuestion');
  }

  save() {
    console.log('save');
  }
}
