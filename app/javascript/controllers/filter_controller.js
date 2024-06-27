import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['text', 'tagOptionList', 'tagOption', 'tagList', 'tag'];

  updateFilter(event) {
    this.dispatch('updateFilter', {
      detail: {
        tagIds: this.tagTargets.map((t) => t.dataset.id),
        textFilter: this.textTarget.value.toLowerCase(),
      },
    });
  }

  addTag(event) {
    this.dispatch('addTag', {
      detail: {},
    });
  }
}
