import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    id: String,
  };

  static targets = ['tag', 'tagOption'];

  delete() {
    this.dispatch('delete', {
      detail: {
        id: this.idValue,
      },
    });
  }

  addTag(event) {
    let tagId = event.currentTarget.value;
    if (tagId === -1) return;
    let content = this.tagOptionTargets.find((t) => t.value === tagId);
    content = content.text;
    let existing = this.tagTargets.find((t) => {
      return (
        t.dataset.questionTagIdValue.toString() === tagId.toString() &&
        t.text === content
      );
    });
    if (existing !== undefined) return;

    this.dispatch('addTag', {
      detail: {
        questionId: this.idValue,
        tagId: tagId,
        tagContent: content,
      },
    });
  }
}
