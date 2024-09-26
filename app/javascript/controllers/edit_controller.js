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
    this.tagCount = {};
    this.idConversion = { questions: {}, answers: {}, tags: {} };
  }

  questionCountValueChanged() {
    this.subtitleTarget.innerText = `${this.questionCountValue} questions`;
  }

  quizTitleChange(event) {
    let previous = this.title;
    let current = this.titleTarget.value;
    let action = () => {
      Change.SetQuizName(current);
      this.titleTarget.value = current;
      this.title = current;
    };
    let reverse = () => {
      Change.SetQuizName(previous);
      this.titleTarget.value = previous;
      this.title = previous;
    };
    Undo.add('Change Quiz Name', action, reverse);
  }

  save(event) {
    let changes = Change.GetChanges(this.idConversion);
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
    Change.Reset();
  }

  undo(event) {
    Undo.undo();
  }

  redo(event) {
    Undo.redo();
  }

  newQuestion(event) {
    let selected = this.currentlySelectedValue;
    let id = ID.next();
    let action = () => {
      Change.AddQuestion(id);
      this.dispatch('addQuestion', { detail: { id: id } });
      this.dispatch('selectQuestion', { detail: { questionId: id } });
    };
    let reverse = () => {
      Change.DeleteQuestion(id);
      this.dispatch('deleteQuestion', { detail: { id: id } });
      this.dispatch('selectQuestion', { detail: { questionId: selected } });
    };
    Undo.add('New Question', action, reverse);
  }

  deleteQuestion(event) {
    let selected = this.currentlySelectedValue;
    let id = event.detail.id;
    let question = Change.GetQuestion(id);
    let action = () => {
      Change.DeleteQuestion(id);
      this.dispatch('selectSibling');
      this.dispatch('deleteQuestion', { detail: { id: id } });
    };
    let reverse = () => {
      Change.AddQuestion(id, question);
      this.dispatch('addQuestion', { detail: { id: id } });
      this.dispatch('selectQuestion', { detail: { questionId: id } });
    };
    Undo.add('Delete Question', action, reverse);
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
      Change.AddTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.addTagDisplay(tagId, tagContent);
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.dispatch('addTag', { detail: event.detail });
    };
    let reverse = () => {
      Change.RemoveTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, -1);
      this.deleteTagDisplay(tagId);
      this.dispatch('removeTag', { detail: event.detail });
    };
    Undo.add('Add Tag', action, reverse);
  }

  removeTag(event) {
    let selected = this.currentlySelectedValue;
    let tagId = event.detail.tagId;
    let tagContent = event.detail.tagContent;
    let action = () => {
      Change.RemoveTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      }
      this.modifyTagCount(tagId, tagContent, -1);
      this.deleteTagDisplay(tagId);
      this.dispatch('removeTag', { detail: event.detail });
    };
    let reverse = () => {
      Change.AddTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.addTagDisplay(tagId, tagContent);
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.dispatch('addTag', { detail: event.detail });
    };
    Undo.add('Remove Tag', action, reverse);
  }

  createTag(event) {
    let selected = this.currentlySelectedValue;
    let tagId = ID.next();
    let tagContent = event.detail.tagContent;
    let action = () => {
      Change.CreateTag(event.detail.questionId, tagId, tagContent);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.addTagDisplay(tagId, tagContent);
      }
      this.modifyTagCount(tagId, tagContent, 1);
      this.dispatch('addTag', {
        detail: {
          questionId: event.detail.questionId,
          tagId: tagId,
          tagContent: tagContent,
        },
      });
    };
    let reverse = () => {
      Change.DeleteTag(event.detail.questionId, tagId, tagContent);
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
    Undo.add('Create Tag', action, reverse);
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
    let id = event.detail.id;
    let current = event.detail.current;
    let previous = event.detail.previous;
    let action = () => {
      Change.SetQuestionContent(id, current);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.dispatch('setQuestionContent', {
          detail: { id: id, content: current },
        });
      }
    };
    let reverse = () => {
      Change.SetQuestionContent(id, previous);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.dispatch('setQuestionContent', {
          detail: { id: id, content: previous },
        });
      }
    };
    Undo.add('Change Question Content', action, reverse);
  }

  addAnswer(event) {
    let question_id = event.detail.question_id;
    let answer_id = ID.next();
    let selected = this.currentlySelectedValue;
    let action = () => {
      Change.AddAnswer(question_id, answer_id);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let parent = this.findQuestionContainer(question_id);
        let ad = AnswerDisplay(parent, question_id, answer_id);
        ad.focus();
      }
    };
    let reverse = () => {
      Change.DeleteAnswer(question_id, answer_id);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.deleteAnswerDisplay(answer_id);
      }
    };
    Undo.add('Add Answer', action, reverse);
  }

  // answer controller
  findAnswerContentTextarea(id) {
    return this.answerContentTargets.find(
      (a) => id === a.parentNode.dataset['edit-AnswerIdValue']
    );
  }

  answerContentChange(event) {
    let selected = this.currentlySelectedValue;
    let { question_id, answer_id, current, previous } = event.detail;
    let action = () => {
      Change.SetAnswerContent(question_id, answer_id, current);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let textarea = this.findAnswerContentTextarea(answer_id);
        textarea.value = current;
      }
    };
    let reverse = () => {
      Change.SetAnswerContent(question_id, answer_id, previous);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', {
          detail: { questionId: selected },
        });
      } else {
        let textarea = this.findAnswerContentTextarea(answer_id);
        textarea.value = previous;
      }
    };
    Undo.add('Change Answer Content', action, reverse);
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
    let selected = this.currentlySelectedValue;
    let { question_id, answer_id, current } = event.detail;
    let parent = this.findQuestionContainer(question_id);
    let answer_container = this.findAnswerContainer(answer_id);
    let index = Array.from(
      parent.querySelectorAll('.answer_container')
    ).indexOf(answer_container);
    let action = () => {
      Change.DeleteAnswer(question_id, answer_id);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        this.deleteAnswerDisplay(answer_id);
      }
    };
    let reverse = () => {
      Change.AddAnswer(question_id, answer_id, index);
      Change.SetAnswerContent(question_id, answer_id, current);
      if (this.currentlySelectedValue !== selected) {
        this.dispatch('selectQuestion', { detail: { questionId: selected } });
      } else {
        let parent = this.findQuestionContainer(question_id);
        AnswerDisplay(parent, question_id, answer_id, current, index);
      }
    };
    Undo.add('Delete Answer', action, reverse);
  }
}
