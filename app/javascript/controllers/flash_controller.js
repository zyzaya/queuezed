import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  set(event) {
    this.element.replaceChildren();
    this.element.classList.remove('notice');
    this.element.classList.remove('alert');
    if (event.detail.notice != undefined) {
      this.element.classList.add('notice');
      let p = document.createElement('p');
      p.innerText = event.detail.notice;
      this.element.appendChild(p);
    }
    if (event.detail.alert != undefined) {
      this.element.classList.add('alert');
      let p = document.createElement('p');
      p.innerText = event.detail.alert;
      this.element.appendChild(p);
    }
  }
}
