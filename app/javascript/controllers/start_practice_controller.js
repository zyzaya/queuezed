import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tagFilter', 'textFilter', 'reviewFilter'];

  updateFilter(event) {
    this.tagFilterTarget.value = event.detail.tagFilter;
    this.textFilterTarget.value = event.detail.textFilter;
    this.reviewFilterTarget.value = event.detail.reviewFilter;
    console.log(event.detail);
  }
}
