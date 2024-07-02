import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tagIds', 'textFilter'];

  updateFilter(event) {
    this.tagIdsTarget.value = event.detail.tagIds;
    this.textFilterTarget.value = event.detail.textFilter;
    console.log(event.detail);
  }
}
