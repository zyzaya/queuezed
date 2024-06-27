import { Controller } from '@hotwired/stimulus';
import TagFilterDisplay from '../edit/TagFilterDisplay';

export default class extends Controller {
  static targets = ['text', 'tagOption', 'tagList', 'tag'];

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

    if (this.hasTag(id, content)) return;
    let tag = TagFilterDisplay(id, content);
    // maintain sorted order of displayed tags
    if (this.tagListTarget.children.length === 0) {
      this.tagListTarget.appendChild(tag);
    } else {
      let next = Array.from(this.tagListTarget.children).find(
        (t) => content.localeCompare(t.text) <= 0
      );
      this.tagListTarget.insertBefore(tag, next);
    }

    this.updateFilter();
  }

  removeTag(event) {
    let id = event.currentTarget.dataset.id;
    let option = document.querySelector(`.button.tagFilter[data-id="${id}"]`);
    if (option !== null) option.remove();
    this.updateFilter();
  }

  hasTag(id, content) {
    let existing = this.tagTargets.find((t) => {
      return t.dataset.id.toString() == id.toString() && t.text === content;
    });
    return existing !== undefined;
  }
}
