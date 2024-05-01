import { Controller } from '@hotwired/stimulus';
import { zGrid } from 'zGrid';
import Data from 'edit/Data';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import ID from 'edit/ID';
import AnswerDisplay from '../edit/AnswerDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
  };

  // let btn_save = document.getElementById('save');
  // btn_save.onclick = () => {
  //   Data.save(csrf, quiz_id, change.getChanges());
  // };

  initialize() {
    let parent = document.createElement('div');
    this.zgrid = new zGrid({
      parent: parent,
      data: [],
      columns: [
        {
          id: 'id',
          visible: false,
        },
        {
          id: 'content',
          name: 'Question',
        },
        {
          id: 'current_streak',
          name: 'Streak',
        },
        {
          id: 'longest_streak',
          name: 'Best Streak',
        },
      ],
      className: {
        tbody: 'zgrid_body',
        tr: 'zgrid_tr',
      },
      dataAttribute: {
        tr: ['action', 'click->zgrid#select'],
      },
    });
    this.previouslySelected = null;
    this.currentlySelected = null;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.undo_handler = Undo();
    this.change_handler = Change(this.csrf, this.quizIdValue);
  }

  connect() {
    this.element.replaceChildren();
    this.zgrid.reconfigure({
      parent: this.element,
    });
    this.refresh();
  }

  refresh(event) {
    return Data.getQuestions(this.quizIdValue)
      .then((questions) => {
        let data = questions.map((e) => {
          return {
            id: e.id.toString(),
            content: e.content,
            current_streak: e.current_streak,
            longest_streak: e.longest_streak,
          };
        });
        this.zgrid.reconfigure({
          data: data,
        });
        let body = document.getElementsByClassName('zgrid_body');
        if (body.length === 1) {
          let grid_data = this.zgrid.getData();
          body = body[0];
          Array.from(body.children).forEach((r, i) => {
            r.dataset['questionIdValue'] = grid_data[i].id;
          });
        }
      })
      .then(() => {
        if (event !== undefined)
          this.setSelectedQuestion(event.detail.selectedId);
      });
  }

  setSelectedQuestion(id) {
    let element = document.querySelector(`[data-question-id-value='${id}']`);
    if (element !== undefined) {
      this.previouslySelected = this.currentlySelected;
      if (this.previouslySelected !== null) {
        this.previouslySelected.classList.remove('active_question');
      }
      element.classList.add('active_question');
      this.currentlySelected = element;
      Data.setQuestion(this.csrf, this.quizIdValue, id);
    }
  }

  setSelectedToSibling() {
    let question_id = this.currentlySelected.dataset.questionIdValue;
    let data = this.zgrid.getData();
    let current = data.findIndex((e) => e.id === question_id);
    if (current === -1) return;
    if (current + 1 < data.length) {
      let sibling = data[current + 1];
      this.setSelectedQuestion(sibling['id']);
    } else if (current - 1 >= 0) {
      let sibling = data[current - 1];
      this.setSelectedQuestion(sibling['id']);
    }
  }

  select(event) {
    this.setSelectedQuestion(event.currentTarget.dataset.questionIdValue);
  }

  newQuestion(event) {
    Data.newQuestion(this.csrf, this.quizIdValue).then((question) => {
      this.refresh().then((response) => this.setSelectedQuestion(question.id));
    });
  }

  deleteQuestion(event) {
    let question_id = this.currentlySelected.dataset.questionIdValue;
    let action = () => {
      this.setSelectedToSibling();
      let sibling_id = this.currentlySelected.dataset.questionIdValue;
      Data.deleteQuestion(this.csrf, this.quizIdValue, question_id)
        .then(() => this.refresh())
        .then(() => this.setSelectedQuestion(sibling_id));
    };
    let reverse = () => {
      Data.restoreQuestion(this.csrf, this.quizIdValue, question_id)
        .then((response) => response.json())
        .then((question) => this.refresh())
        .then(() => this.setSelectedQuestion(question_id));
    };
    this.undo_handler.add('Delete Question', action, reverse);
  }

  deleteAnswerDisplay(id) {
    let answer = document.querySelector(
      `.answer_container[data-answer-id-value="${id}"]`
    );
    answer.remove();
  }

  addAnswer(event) {
    let answer_id = ID.next();
    let action = () => {
      this.change_handler.addAnswer(event.detail.questionId, answer_id);
      AnswerDisplay(event.detail.parent, event.detail.questionId, answer_id);
    };
    let reverse = () => {
      this.change_handler.deleteAnswer(event.detail.questionId, answer_id);
      this.deleteAnswer(answer_id);
    };
    this.undo_handler.add('Add Answer', action, reverse);
  }

  deleteAnswer(event) {
    let question_id = this.currentlySelected.dataset.questionIdValue;
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

  answerContentChange(event) {
    let question_id = this.currentlySelected.dataset.questionIdValue;
    let action = () => {
      this.change_handler.setAnswerContent(
        question_id,
        event.detail.id,
        event.detail.current
      );
      event.detail.textarea.value = event.detail.current;
    };
    let reverse = () => {
      this.change_handler.setAnswerContent(
        question_id,
        event.detail.id,
        event.detail.previous
      );
      event.detail.textarea.value = event.detail.previous;
    };
    this.undo_handler.add('Change Answer Content', action, reverse);
  }

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

  quizTitleChange(event) {
    let action = () => {
      this.change_handler.setQuizTitle(event.detail.current);
      event.detail.input.value = event.detail.current;
    };
    let reverse = () => {
      this.change_handler.setQuizTitle(event.detail.previous);
      event.detail.input.value = event.detail.previous;
    };
    this.undo_handler.add('Change Quiz Title', action, reverse);
  }

  undo(event) {
    this.undo_handler.undo();
  }

  redo(event) {
    this.undo_handler.redo();
  }
}
