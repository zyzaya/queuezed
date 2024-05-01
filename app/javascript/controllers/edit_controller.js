import { Controller } from '@hotwired/stimulus';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import Data from 'edit/Data';

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
}
