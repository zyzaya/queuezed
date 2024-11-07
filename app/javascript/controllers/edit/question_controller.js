import { Controller } from '@hotwired/stimulus';
import TagDisplay from '../../display/TagDisplay';
import SingleQuestionDisplay from '../../display/SingleQuestionDisplay';
import RelatedOptionDisplay from '../../display/RelatedOptionDisplay';

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
    'relationContainer',
    'addRelatedList',
    'addRelatedOption',
    'limitRelated',
    'createTag',
  ];

  focusCreateTag(event) {
    this.createTagTarget.focus();
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
        question_id: this.idValue,
        tag_id: tagId,
        content: content,
      },
    });
  }

  removeTag(event) {
    let tag_id = event.currentTarget.dataset['edit-QuestionTagIdValue'];
    let content = event.currentTarget.text;
    this.dispatch('removeTag', {
      detail: {
        question_id: this.idValue,
        tag_id: tag_id,
        content: content,
      },
    });
  }

  createTag(event) {
    let content = event.currentTarget.value;
    event.currentTarget.value = '';
    if (this.hasTag(content)) return;

    let tag_id = this.findTagId(content);
    if (tag_id !== undefined) {
      this.dispatch('addTag', {
        detail: {
          question_id: this.idValue,
          tag_id: tag_id,
          content: content,
        },
      });
    } else {
      this.dispatch('createTag', {
        detail: {
          question_id: this.idValue,
          content: content,
        },
      });
    }
  }

  set(event) {
    if (event.detail.id === '') {
      this.element.classList.add('question_hidden');
    } else {
      this.element.classList.remove('question_hidden');
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
      single.getElementsByClassName('question_content')[0].focus();

      event.detail.relations.forEach((r) => {
        let relation = SingleQuestionDisplay(r.id, r.content, r.answers, true);
        this.relationContainerTarget.appendChild(relation);
      });

      this.updateAddRelatedOptions();
    }
  }

  // related questions
  updateQuestionList(event) {
    this.question_list = event.detail.data.sort((a, b) =>
      a['content'].localeCompare(b['content'])
    );
    if (this.filtered_question_list === undefined)
      this.filtered_question_list = event.detail.data;
  }

  updateFilteredQuestionList(event) {
    this.filtered_question_list = event.detail.data.sort((a, b) =>
      a['content'].localeCompare(b['content'])
    );
    if (this.limitRelatedTarget.checked) {
      this.setAddRelatedOptions(this.filtered_question_list);
    }
  }

  setAddRelatedOptions(questions) {
    this.addRelatedOptionTargets.forEach((e) => e.remove());
    questions.forEach((e) => {
      if (e['id'] != this.idValue) {
        this.addRelatedListTarget.appendChild(
          RelatedOptionDisplay(e['id'], e['content'])
        );
      }
    });
  }

  enableRelatedLimit(event) {
    this.updateAddRelatedOptions();
  }

  updateAddRelatedOptions() {
    if (this.limitRelatedTarget.checked) {
      this.setAddRelatedOptions(this.filtered_question_list);
    } else {
      this.setAddRelatedOptions(this.question_list);
    }
  }

  hasRelated(id) {
    let existing = this.singleQuestionContainerTargets.find((c) => {
      return c.dataset['edit-SingleQuestionIdValue'] == id;
    });
    return existing !== undefined;
  }

  addRelated(event) {
    let related_id = event.target.value;
    event.currentTarget.value = '-1';
    if (related_id == '-1' || this.hasRelated(related_id)) return;

    if (related_id != this.idValue) {
      this.dispatch('addRelated', {
        detail: {
          question_id: this.idValue,
          related_id: related_id,
        },
      });
    }
  }
}
