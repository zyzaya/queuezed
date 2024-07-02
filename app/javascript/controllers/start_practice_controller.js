import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.tagIds = [];
    this.textFilter = '';
  }

  updateFilter(event) {
    this.tagIds = event.detail.tagIds;
    this.textFilter = event.detail.textFilter;
    console.log(event.detail);
  }

  start() {}
}
