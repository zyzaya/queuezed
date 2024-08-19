import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    id: String,
  };

  static targets = ['tag', 'tagOption', 'tagOptionList'];

  connect() {
    this.dispatch('load', {
      detail: {
        questionId: this.idValue,
      },
    });
  }

  delete() {
    this.dispatch('delete', {
      detail: {
        id: this.idValue,
      },
    });
  }
  // determines if the question has the specified tag
  hasTag(id, content) {
    let existing = this.tagTargets.find((t) => {
      return (
        t.dataset.questionTagIdValue.toString() === id.toString() &&
        t.text === content
      );
    });
    return existing !== undefined;
  }

  findTagId(content) {
    let id = this.tagOptionTargets.find((t) => t.text === content);
    return id === undefined ? undefined : id.value;
  }

  addTag(event) {
    let tagId = event.currentTarget.value;
    event.currentTarget.value = '-1';
    if (tagId.toString() === (-1).toString()) return;
    let content = this.tagOptionTargets.find((t) => t.value === tagId);
    content = content.text;

    if (this.hasTag(tagId, content)) return;

    this.dispatch('addTag', {
      detail: {
        questionId: this.idValue,
        tagId: tagId,
        tagContent: content,
      },
    });
  }

  removeTag(event) {
    let tagId = event.currentTarget.dataset.questionTagIdValue;
    let content = event.currentTarget.text;
    this.dispatch('removeTag', {
      detail: {
        questionId: this.idValue,
        tagId: tagId,
        tagContent: content,
      },
    });
  }

  createTag(event) {
    let content = event.currentTarget.value;
    event.currentTarget.value = '';
    if (this.hasTag(content)) return;

    let tagId = this.findTagId(content);
    if (tagId !== undefined) {
      this.dispatch('addTag', {
        detail: {
          questionId: this.idValue,
          tagId: tagId,
          tagContent: content,
        },
      });
    } else {
      this.dispatch('createTag', {
        detail: {
          questionId: this.idValue,
          tagContent: content,
        },
      });
    }
  }
}
