import { Controller } from '@hotwired/stimulus';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import Data from 'edit/Data';
import ID from 'edit/ID';
import AnswerDisplay from '../display/AnswerDisplay';
import TagDisplay from '../display/TagDisplay';
import TagOptionDisplay from '../display/TagOptionDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
    currentlySelected: String,
    questionCount: Number,
  };

  static targets = [
    'title',
    'subtitle',
    'questionContent',
    'answerContent',
    'singleQuestionContainer',
    'tagList',
    'tagOptionList',
    'tagFilterOptionList',
  ];

  initialize() {
    this.title = this.titleTarget.value;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.undo_handler = Undo();
    this.change_handler = Change(this.csrf, this.quizIdValue);
    this.tagCount = {};
    this.idConversion = { answers: {}, tags: {} };
  }

  questionCountValueChanged() {
    this.subtitleTarget.innerText = `${this.questionCountValue} questions`;
  }

  quizTitleChange(event) {
    let previous = this.title;
    let current = this.titleTarget.value;
    let action = () => {
      this.change_handler.setQuizTitle(current);
      this.titleTarget.value = current;
      this.title = current;
    };
    let reverse = () => {
      this.change_handler.setQuizTitle(previous);
      this.titleTarget.value = previous;
      this.title = previous;
    };
    this.undo_handler.add('Change Quiz Title', action, reverse);
  }

  save(event) {
    let changes = this.change_handler.getChanges(this.idConversion);
    let ids = {
      questions: {},
      answers: {},
      tags: {},
    };
    Data.save(this.csrf, this.quizIdValue, changes).then((data) => {
      // collect id conversion
      data.questions.forEach((q) => {
        if (q.prev_id !== undefined) ids.questions[q.prev_id] = q.id;
        q.answers.forEach((a) => {
          if (a.prev_id !== undefined) ids.answers[a.prev_id] = a.id;
        });
        q.tags.forEach((t) => {
          if (t.prev_id !== undefined) ids.tags[t.prev_id] = t.id;
        });
      });
      this.idConversion = ids;
    });
    this.change_handler.resetChanges();
  }

  undo(event) {
    this.undo_handler.undo();
  }

  redo(event) {
    this.undo_handler.redo();
  }

  newQuestion(event) {
    let question_id = null;
    let selected = this.currentlySelectedValue;
    let count = this.questionCountValue;
    let changes = this.change_handler.getChanges();
    Data.newQuestion(this.csrf, this.quizIdValue)
      .then((question) => {
        question_id = question.id;
        this.dispatch('refresh', {
          detail: { selectedId: question.id, changes: changes },
        });
        this.questionCountValue = count + 1;
      })
      .then(() => (this.questionCountValue = count + 1));
    let triggered = false;
    let action = () => {
      if (triggered) {
        Data.restoreQuestion(this.csrf, this.quizIdValue, question_id).then(
          () => {
            this.dispatch('refresh', {
              detail: { selectedId: question_id, changes: changes },
            });
            this.questionCountValue = count + 1;
          }
        );
      }
      triggered = true;
    };
    let reverse = () => {
      Data.deleteQuestion(this.csrf, this.quizIdValue, question_id).then(() => {
        this.dispatch('refresh', {
          detail: { selectedId: selected, changes: changes },
        });
        this.questionCountValue = count;
      });
    };
    this.undo_handler.add('Create Question', action, reverse);
  }

  // question-controller
  loadQuestion(event) {
    this.questionContentTarget.focus();
    this.questionContentTarget.selectionStart = 10000;
    this.questionContentTarget.selectionEnd = 10000;

    let changes = this.change_handler.getChanges();
    changes.questions.forEach((q) => {
      q.tags?.forEach((t) => {
        if (t.meta === 'new') this.addQuestionTagOption(t.id, t.content);
      });
    });

    let question = changes.questions.find(
      (q) => q.id === event.detail.questionId
    );

    if (question !== undefined) {
      if (question.tags !== undefined) {
        question.tags.forEach((t) => {
          if (t.meta === 'add' || t.meta === 'new') {
            this.addTagDisplay(t.id, t.content);
          } else if (t.meta === 'remove') {
            this.deleteTagDisplay(t.id);
          }
        });
      }
    }
  }

  deleteQuestion(event) {
    let question_id = event.detail.id;
    let count = this.questionCountValue;
    let changes = this.change_handler.getChanges();
    let action = () => {
      this.dispatch('selectSibling');
      Data.deleteQuestion(this.csrf, this.quizIdValue, question_id).then(() => {
        this.dispatch('refresh', {
          detail: { changes: changes },
        });
        this.questionCountValue = count - 1;
      });
    };
    let reverse = () => {
      Data.restoreQuestion(this.csrf, this.quizIdValue, question_id)
        .then((response) => response.json())
        .then((question) => {
          this.dispatch('refresh', {
            detail: { selectedId: question_id, changes: changes },
          });
          this.questionCountValue = count;
        });
    };
    this.undo_handler.add('Delete Question', action, reverse);
  }

  loadSingleQuestion(event) {
    let textarea = this.questionContentTargets.find((q) => {
      let id = q.parentNode.dataset.singleQuestionIdValue;
      return id === event.detail.questionId;
    });
    let question = this.change_handler
      .getChanges()
      .questions.find((q) => q.id === event.detail.questionId);
    if (question === undefined) return;
    if (question.content !== undefined) textarea.value = question.content;
    if (question.answers !== undefined) {
      question.answers.forEach((a) => {
        if (a.meta === 'new') {
          AnswerDisplay(event.detail.parent, question.id, a.id); // add answer with id a.id
        } else if (a.meta === 'delete') {
          this.deleteAnswerDisplay(a.id);
        }
      });
    }
  }
  // tags
  setTagCount(event) {
    this.tagCount = event.detail.tagCount;
  }

  modifyTagCount(id, content, delta) {
    if (delta > 0) {
      if (this.tagCount[id] === undefined) {
        this.tagCount[id] = 1;
        this.addQuestionTagOption(id, content);
        this.addTagFilterOption(id, content);
      } else {
        this.tagCount[id] += 1;
      }
    } else if (delta < 0) {
      if (this.tagCount[id] === 1) {
        delete this.tagCount[id];
        this.deleteTagOption(id);
      } else {
        this.tagCount[id] -= 1;
      }
    }
  }

  addTagDisplay(id, content) {
    let display = TagDisplay(id, content);
    // maintain sorted order of displayed tags
    if (this.tagListTarget.children.length === 0) {
      this.tagListTarget.appendChild(display);
    } else {
      let next = Array.from(this.tagListTarget.children).find(
        (t) => content.localeCompare(t.text) <= 0
      );
      this.tagListTarget.insertBefore(display, next);
    }
  }

  deleteTagDisplay(id) {
    let tag = document.querySelector(
      `.button.tag[data-edit--question-tag-id-value="${id}"]`
    );
    if (tag !== null) tag.remove();
  }

  addQuestionTagOption(id, content) {
    let option = TagOptionDisplay(id, content);
    option.dataset.questionTarget = 'tagOption';

    // add to question display
    if (this.tagOptionListTarget.children.length === 2) {
      this.tagOptionListTarget.appendChild(option);
    } else {
      let next = Array.from(this.tagOptionListTarget.children).find((t) => {
        return t.value != -1 && content.localeCompare(t.text) <= 0;
      });
      this.tagOptionListTarget.insertBefore(option, next);
    }
    // add to filter display
  }

  addTagFilterOption(id, content) {
    let filter = TagOptionDisplay(id, content);
    filter.dataset.filterTarget = 'tagOption';

    if (this.tagFilterOptionListTarget.children.length === 2) {
      this.tagFilterOptionListTarget.appendChild(filter);
    } else {
      let next = Array.from(this.tagFilterOptionListTarget.children).find(
        (t) => {
          return t.value != -1 && content.localeCompare(t.text) <= 0;
        }
      );
      this.tagFilterOptionListTarget.insertBefore(filter, next);
    }
  }

  deleteTagOption(id) {
    // remove from question display
    let option = document.querySelector(`.add_tag > option[value="${id}"`);
    if (option !== null) option.remove();
    // remove from filter display
    let filter = document.querySelector(
      `.add_tag_filter > option[value="${id}"]`
    );
    if (filter !== null) filter.remove();
  }

  addTag(event) {
    let selected = this.currentlySelectedValue;
    let tagContent = event.detail.tagContent;
    let tagId = event.detail.tagId;
    let action = () => {
      this.change_handler.addTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.addTagDisplay(tagId, tagContent);
      this.dispatch('addTag', { detail: event.detail });
    };
    let reverse = () => {
      this.change_handler.removeTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, -1);
      this.deleteTagDisplay(tagId);
      this.dispatch('removeTag', { detail: event.detail });
    };
    this.undo_handler.add('Add Tag', action, reverse);
  }

  removeTag(event) {
    console.log('edit_controller remove tag');
    let selected = this.currentlySelectedValue;
    let tagId = event.detail.tagId;
    let tagContent = event.detail.tagContent;
    let action = () => {
      this.change_handler.removeTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, -1);
      this.deleteTagDisplay(tagId);
      this.dispatch('removeTag', { detail: event.detail });
    };
    let reverse = () => {
      this.change_handler.addTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.addTagDisplay(tagId, tagContent);
      this.dispatch('addTag', { detail: event.detail });
    };
    this.undo_handler.add('Remove Tag', action, reverse);
  }

  createTag(event) {
    let selected = this.currentlySelectedValue;
    let tagId = ID.next();
    let tagContent = event.detail.tagContent;
    let action = () => {
      this.change_handler.createTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.addTagDisplay(tagId, tagContent);
      this.dispatch('addTag', {
        detail: {
          questionId: event.detail.questionId,
          tagId: tagId,
          tagContent: tagContent,
        },
      });
    };
    let reverse = () => {
      this.change_handler.deleteTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, -1);
      this.deleteTagDisplay(tagId);
      this.dispatch('removeTag', {
        detail: {
          questionId: event.detail.questionId,
          tagId: tagId,
          tagContent: tagContent,
        },
      });
    };
    this.undo_handler.add('Create Tag', action, reverse);
  }

  // single-question controller
  findQuestionContentTextarea(id) {
    return this.questionContentTargets.find(
      (q) => id === q.dataset.singleQuestionIdValue
    );
  }

  findQuestionContainer(id) {
    return this.singleQuestionContainerTargets.find(
      (c) => id === c.dataset['edit-SingleQuestionIdValue']
    );
  }

  questionContentChange(event) {
    let selected = this.currentlySelectedValue;
    let action = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.current
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let textarea = this.findQuestionContentTextarea(
          event.detail.questionId
        );
        textarea.value = event.detail.current;
      }
      this.dispatch('questionContentChange', {
        detail: {
          questionId: event.detail.questionId,
          questionContent: event.detail.current,
        },
      });
    };
    let reverse = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.previous
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let textarea = this.findQuestionContentTextarea(
          event.detail.questionId
        );
        textarea.value = event.detail.previous;
      }
      this.dispatch('questionContentChange', {
        detail: {
          questionId: event.detail.questionId,
          questionContent: event.detail.previous,
        },
      });
    };
    this.undo_handler.add('Change Question Content', action, reverse);
  }

  addAnswer(event) {
    let answer_id = ID.next();
    let selected = this.currentlySelectedValue;
    let action = () => {
      this.change_handler.addAnswer(event.detail.questionId, answer_id);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let parent = this.findQuestionContainer(event.detail.questionId);
        let ad = AnswerDisplay(parent, event.detail.questionId, answer_id);
        ad.focus();
      }
    };
    let reverse = () => {
      this.change_handler.deleteAnswer(event.detail.questionId, answer_id);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.deleteAnswerDisplay(answer_id);
      }
    };
    this.undo_handler.add('Add Answer', action, reverse);
  }

  // answer controller
  findAnswerContentTextarea(id) {
    return this.answerContentTargets.find(
      (a) => id === a.parentNode.dataset['edit-AnswerIdValue']
    );
  }

  loadAnswer(event) {
    let question = this.change_handler
      .getChanges()
      .questions.find((q) => q.id === event.detail.questionId);
    if (question === undefined || question.answers === undefined) return;
    let answer = question.answers.find((a) => a.id === event.detail.answerId);
    if (answer === undefined || answer.content == undefined) return;
    let textarea = this.findAnswerContentTextarea(event.detail.answerId);
    textarea.value = answer.content;
  }

  answerContentChange(event) {
    let selected = this.currentlySelectedValue;
    let action = () => {
      this.change_handler.setAnswerContent(
        event.detail.questionId,
        event.detail.answerId,
        event.detail.current
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let textarea = this.findAnswerContentTextarea(event.detail.answerId);
        textarea.value = event.detail.current;
      }
    };
    let reverse = () => {
      this.change_handler.setAnswerContent(
        event.detail.questionId,
        event.detail.answerId,
        event.detail.previous
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', {
          detail: { questionId: selected },
        });
      } else {
        let textarea = this.findAnswerContentTextarea(event.detail.answerId);
        textarea.value = event.detail.previous;
      }
    };
    this.undo_handler.add('Change Answer Content', action, reverse);
  }

  findAnswerContainer(id) {
    return document.querySelector(
      `.answer_container[data-edit--answer-id-value="${id}"]`
    );
  }

  deleteAnswerDisplay(id) {
    let answer = this.findAnswerContainer(id);
    if (answer !== null) answer.remove();
  }

  deleteAnswer(event) {
    console.log('delete answer');
    let selected = this.currentlySelectedValue;
    let parent = this.findQuestionContainer(event.detail.questionId);
    let answer_container = this.findAnswerContainer(event.detail.answerId);
    let index = Array.from(
      parent.querySelectorAll('.answer_container')
    ).indexOf(answer_container);
    let action = () => {
      this.change_handler.deleteAnswer(
        event.detail.questionId,
        event.detail.answerId
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.deleteAnswerDisplay(event.detail.answerId);
      }
    };
    let reverse = () => {
      this.change_handler.addAnswer(
        event.detail.questionId,
        event.detail.answerId
      );
      this.change_handler.setAnswerContent(
        event.detail.questionId,
        event.detail.answerId,
        event.detail.current
      );
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let parent = this.findQuestionContainer(event.detail.questionId);
        AnswerDisplay(
          parent,
          event.detail.questionId,
          event.detail.answerId,
          event.detail.current,
          index
        );
      }
    };
    this.undo_handler.add('Delete Answer', action, reverse);
  }
}
