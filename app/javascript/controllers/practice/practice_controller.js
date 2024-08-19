import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];

  connect() {
    this.current = 0;
  }

  inputTargetConnected(element) {
    let index = this.inputTargets.findIndex((e) => e == element);
    if (index == 0) element.focus();
    element.dataset.practiceIndexParam = index;
  }

  PreviousAnswer(event) {
    event.preventDefault();
    if (this.current == 0) return;
    this.current -= 1;
    this.inputTargets[this.current].focus();
  }

  NextAnswer(event) {
    if (this.current >= this.inputTargets.length - 1) return;
    event.preventDefault();
    this.current += 1;
    this.inputTargets[this.current].focus();
  }

  ChangeAnswer(event) {
    if (event.key == 'Enter') {
      if (event.shiftKey) this.PreviousAnswer(event);
      else this.NextAnswer(event);
    }
  }

  FocusAnswer(event) {
    this.current = event.params.index;
  }
}
