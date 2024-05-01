import { Controller } from '@hotwired/stimulus';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import Data from 'edit/Data';
import ID from 'edit/ID';
import AnswerDisplay from '../edit/AnswerDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
  };

  static targets = ['title'];

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

  save(event) {}

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

  // question-controller
  deleteQuestion(event) {
    console.log(event.detail.id);
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

  // single-question controller
  questionContentChange(event) {
    let action = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.current
      );
      event.detail.textarea.value = event.detail.current;
    };
    let reverse = () => {
      this.change_handler.setQuestionContent(
        event.detail.questionId,
        event.detail.previous
      );
      event.detail.textarea.value = event.detail.previous;
    };
    this.undo_handler.add('Change Question Content', action, reverse);
  }

  addAnswer(event) {
    let answer_id = ID.next();
    let action = () => {
      this.change_handler.addAnswer(event.detail.questionId, answer_id);
      AnswerDisplay(event.detail.parent, event.detail.questionId, answer_id);
    };
    let reverse = () => {
      this.change_handler.deleteAnswer(event.detail.questionId, answer_id);
      this.deleteAnswer({ detail: { answerId: answer_id } });
    };
    this.undo_handler.add('Add Answer', action, reverse);
  }

  // answer controller
  deleteAnswerDisplay(id) {
    let answer = document.querySelector(
      `.answer_container[data-answer-id-value="${id}"]`
    );
    answer.remove();
  }

  deleteAnswer(event) {
    let question_id = this.currentlySelected;
    let action = () => {
      this.change_handler.deleteAnswer(question_id, event.detail.answerId);
      this.deleteAnswerDisplay(event.detail.answerId);
    };
    let reverse = () => {
      this.change_handler.addAnswer(question_id, event.detailanswerId);
      this.change_handler.setAnswerContent(
        question_id,
        event.detail.answerId,
        event.detail.current
      );
      AnswerDisplay(
        event.detail.parent,
        question_id,
        event.detail.answerId,
        event.detail.current
      );
    };
    this.undo_handler.add('Delete Answer', action, reverse);
  }
}
