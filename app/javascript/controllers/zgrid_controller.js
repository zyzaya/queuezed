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

  static targets = ['body', 'row'];

  initialize() {
    let parent = document.createElement('div');

    this.zgrid = new zGrid({
      parent: parent,
      data: [],
      columns: [
        {
          id: 'id',
          visible: true,
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
        tr: ['zgridTarget', 'row'],
        tbody: ['zgridTarget', 'body'],
      },
    });
    this.previouslySelected = null;
    this.currentlySelected = null;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.undo_handler = Undo();
    this.change_handler = Change(this.csrf, this.quizIdValue);
  }

  rowTargetConnected(element) {
    element.dataset.action = 'click->zgrid#select';
    let nodes = element.parentNode.children.length;
    let grid_data = this.zgrid.getData();
    if (nodes === grid_data.length) {
      let index = Array.from(element.parentNode.children).findIndex(
        (e) => e === element
      );
      element.dataset.questionIdValue = grid_data[index].id;
      if (this.currentlySelected === grid_data[index].id)
        element.classList.add('active_question');
    }
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

        this.zgrid.reconfigure({ data: data });
      })
      .then(() => {
        if (event !== undefined && event.detail.selectedId !== undefined) {
          this.setSelectedQuestion(event.detail.selectedId);
        } else if (this.currentlySelected !== null) {
          this.setSelectedQuestion(this.currentlySelected);
        }
      });
  }

  select(event) {
    if (event.currentTarget.parentNode.nodeName === 'THEAD') return;
    this.setSelectedQuestion(event.currentTarget.dataset.questionIdValue);
  }

  setSelectedQuestion(id) {
    let element = document.querySelector(`[data-question-id-value='${id}']`);
    if (element !== null) {
      this.previouslySelected = this.currentlySelected;
      let previous_element = document.querySelector(
        `[data-question-id-value='${this.previouslySelected}']`
      );
      if (previous_element !== null) {
        previous_element.classList.remove('active_question');
      }
      element.classList.add('active_question');
      this.currentlySelected = id;
      Data.setQuestion(this.csrf, this.quizIdValue, id);
    }
  }

  setSelectedToSibling() {
    let question_id = this.currentlySelected;
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
}
