import { Controller } from '@hotwired/stimulus';
import TagFilterDisplay from '../display/TagFilterDisplay';

export default class extends Controller {
  static targets = ['text', 'tagOption', 'tagList', 'tag'];

  updateFilter() {
    let text = this.textTarget.value.toLowerCase();
    let tag = this.tagTargets.map((t) => t.dataset.id);
    let review = tag.includes('review');
    let difficult = tag.includes('difficult');
    tag = tag.filter((t) => !['review', 'difficult'].includes(t));

    this.dispatch('updateFilter', { detail: { tag, text, review, difficult } });
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
    event.currentTarget.value = '-1';

    this.updateFilter();
  }

  removeTag(event) {
    let id = event.currentTarget.dataset.id;
    let option = document.querySelector(`.filter_tag[data-id="${id}"]`);
    if (option !== null) option.remove();
    this.updateFilter();
  }

  hasTag(id, content) {
    let existing = this.tagTargets.find((t) => {
      return t.dataset.id.toString() == id.toString() && t.text === content;
    });
    return existing !== undefined;
  }

  focus(event) {
    this.textTarget.focus();
  }
}
