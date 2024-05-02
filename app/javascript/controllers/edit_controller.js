import { Controller } from '@hotwired/stimulus';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import Data from 'edit/Data';
import ID from 'edit/ID';
import AnswerDisplay from '../edit/AnswerDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
    currentlySelected: String,
  };

  static targets = [
    'title',
    'questionContent',
    'answerContent',
    'singleQuestionContainer',
  ];

  initialize() {
    this.previous_title = '';
    this.current_title = this.titleTarget.value;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.undo_handler = Undo();
    this.change_handler = Change(this.csrf, this.quizIdValue);
  }

  quizTitleChange(event) {
    this.previous_title = this.current_title;
    this.current_title = this.titleTarget.value;
    this.dispatch('quizTitleChange', {
      detail: {
        current: this.current_title,
        previous: this.previous_title,
        input: this.titleTarget,
      },
    });
  }

  save(event) {
    Data.save(this.csrf, this.quizIdValue, this.change_handler.getChanges());
  }

  undo(event) {
    this.undo_handler.undo();
  }

  redo(event) {
    this.undo_handler.redo();
  }

  newQuestion(event) {
    Data.newQuestion(this.csrf, this.quizIdValue).then((question) => {
      this.dispatch('refresh', {
        detail: {
          selectedId: question.id,
        },
      });
    });
  }

  select(event) {
    let id = this.currentlySelectedValue;
    if (event.currentTarget.parentNode.nodeName === 'THEAD') return;
    this.dispatch('selectQuestion', {
      detail: {
        questionId: event.params.questionId,
      },
    });
  }

  // question-controller
  deleteQuestion(event) {
    let question_id = event.detail.id;
    let action = () => {
      this.dispatch('selectSibling');
      Data.deleteQuestion(this.csrf, this.quizIdValue, question_id).then(() =>
        this.dispatch('refresh')
      );
    };
    let reverse = () => {
      Data.restoreQuestion(this.csrf, this.quizIdValue, question_id)
        .then((response) => response.json())
        .then((question) =>
          this.dispatch('refresh', {
            detail: {
              selectedId: question_id,
            },
          })
        );
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

  // single-question controller
  findQuestionContentTextarea(id) {
    return this.questionContentTargets.find(
      (q) => id === q.parentNode.dataset.singleQuestionIdValue
    );
  }

  findQuestionContainer(id) {
    return this.singleQuestionContainerTargets.find(
      (c) => id === c.dataset.singleQuestionIdValue
    );
  }

  questionContentChange(event) {
    let action = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.current
      );
      let textarea = this.findQuestionContentTextarea(event.detail.questionId);
      textarea.value = event.detail.current;
    };
    let reverse = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.previous
      );
      if (this.currentlySelectedValue !== event.detail.questionId) {
        this.dispatch('selectQuestion', {
          detail: { questionId: event.detail.questionId },
        });
      } else {
        let textarea = this.findQuestionContentTextarea(
          event.detail.questionId
        );
        textarea.value = event.detail.previous;
      }
    };
    this.undo_handler.add('Change Question Content', action, reverse);
  }

  addAnswer(event) {
    let answer_id = ID.next();
    let action = () => {
      this.change_handler.addAnswer(event.detail.questionId, answer_id);
      let parent = this.findQuestionContainer(event.detail.questionId);
      AnswerDisplay(parent, event.detail.questionId, answer_id);
    };
    let reverse = () => {
      this.change_handler.deleteAnswer(event.detail.questionId, answer_id);
      if (this.currentlySelectedValue !== event.detail.questionId) {
        this.dispatch('selectQuestion', {
          detail: { questionId: event.detail.questionId },
        });
      } else {
        this.deleteAnswerDisplay(answer_id);
      }
    };
    this.undo_handler.add('Add Answer', action, reverse);
  }

  // answer controller
  findAnswerContentTextarea(id) {
    return this.answerContentTargets.find(
      (a) => id === a.parentNode.dataset.answerIdValue
    );
  }

  loadAnswer(event) {
    let question = this.change_handler
      .getChanges()
      .questions.find((q) => q.id === event.detail.questionId);
    if (question === undefined || question.answers === undefined) return;
    let answer = question.answers.find((a) => a.id === event.detail.answerId);
    if (answer === undefined) return;
    let textarea = this.findAnswerContentTextarea(event.detail.answerId);
    textarea.value = answer.content;
  }

  answerContentChange(event) {
    let action = () => {
      this.change_handler.setAnswerContent(
        event.detail.questionId,
        event.detail.answerId,
        event.detail.current
      );
      let textarea = this.findAnswerContentTextarea(event.detail.answerId);
      textarea.value = event.detail.current;
    };
    let reverse = () => {
      this.change_handler.setAnswerContent(
        event.detail.questionId,
        event.detail.answerId,
        event.detail.previous
      );
      if (this.currentlySelectedValue !== event.detail.questionId) {
        this.dispatch('selectQuestion', {
          detail: { questionId: event.detail.questionId },
        });
      } else {
        let textarea = this.findAnswerContentTextarea(event.detail.answerId);
        textarea.value = event.detail.previous;
      }
    };
    this.undo_handler.add('Change Answer Content', action, reverse);
  }

  deleteAnswerDisplay(id) {
    let answer = document.querySelector(
      `.answer_container[data-answer-id-value="${id}"]`
    );
    if (answer !== null) answer.remove();
  }

  deleteAnswer(event) {
    let action = () => {
      this.change_handler.deleteAnswer(
        event.detail.questionId,
        event.detail.answerId
      );
      this.deleteAnswerDisplay(event.detail.answerId);
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
      AnswerDisplay(
        event.detail.parent,
        event.detail.questionId,
        event.detail.answerId,
        event.detail.current
      );
    };
    this.undo_handler.add('Delete Answer', action, reverse);
  }
}
