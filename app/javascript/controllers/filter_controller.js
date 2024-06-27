import { Controller } from '@hotwired/stimulus';
import TagFilterDisplay from '../edit/TagFilterDisplay';

export default class extends Controller {
  static targets = ['text', 'tagOptionList', 'tagOption', 'tagList', 'tag'];

  updateFilter() {
    this.dispatch('updateFilter', {
      detail: {
        tagIds: this.tagTargets.map((t) => t.dataset.id),
        textFilter: this.textTarget.value.toLowerCase(),
      },
    });
  }

  addTag(event) {
    let id = event.currentTarget.value;
    if (id.toString() == (-1).toString()) return;
    let content = this.tagOptionTargets.find((t) => t.value === id);
    content = content.text;

    if (this.hasTagFilter(id, content)) return;
    let tag = TagFilterDisplay(id, content);
    this.tagListTarget.appendChild(tag);
    this.updateFilter();
  }

  removeTagFilter(event) {
    let id = event.currentTarget.dataset.id;
    let option = document.querySelector(`.button.tagFilter[data-id="${id}"]`);
    if (option !== null) option.remove();
    this.updateFilter();
  }

  hasTagFilter(id, content) {
    let existing = this.tagTargets.find((t) => {
      return t.dataset.id.toString() == id.toString() && t.text === content;
    });
    return existing !== undefined;
  }
}
