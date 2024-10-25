import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tagFilter', 'textFilter', 'reviewFilter'];

  updateFilter(event) {
    this.tagFilterTarget.value = event.detail.tag;
    this.textFilterTarget.value = event.detail.text;
    this.reviewFilterTarget.value = event.detail.review;
  }
}
