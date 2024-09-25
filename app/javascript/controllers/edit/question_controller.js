import { Controller } from '@hotwired/stimulus';
import TagDisplay from '../../display/TagDisplay';
import SingleQuestionDisplay from '../../display/SingleQuestionDisplay';

export default class extends Controller {
  static values = {
    id: String,
  };

  static targets = [
    'tag',
    'tagList',
    'tagOption',
    'tagOptionList',
    'singleQuestionContainer',
    'singleStart',
    'relationStart',
  ];

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
        t.dataset['edit-QuestionTagIdValue'].toString() === id.toString() &&
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
    let tagId = event.currentTarget.dataset['edit-QuestionTagIdValue'];
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

  set(event) {
    this.idValue = event.detail.id;
    this.tagTargets.forEach((t) => t.remove());
    let tags = event.detail.tags.sort((a, b) =>
      a.content.localeCompare(b.content)
    );
    tags.forEach((t) => {
      let display = TagDisplay(t.id, t.content);
      this.tagListTarget.appendChild(display);
    });
    this.singleQuestionContainerTargets.forEach((c) => c.remove());
    let single = SingleQuestionDisplay(
      event.detail.id,
      event.detail.content,
      event.detail.answers
    );
    this.singleStartTarget.after(single);

    event.detail.relations.forEach((r) => {
      let relation = SingleQuestionDisplay(r.id, r.content, r.answers);
      this.relationStartTarget.after(relation);
    });
  }
}
