import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tagFilter', 'textFilter'];

  updateFilter(event) {
    this.tagFilterTarget.value = event.detail.tagFilter;
    this.textFilterTarget.value = event.detail.textFilter;
    console.log(event.detail);
  }
}
