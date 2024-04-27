import { Controller } from '@hotwired/stimulus';
import { zGrid } from 'zGrid';
import Data from 'edit/Data';

export default class extends Controller {
  static values = {
    quizId: String,
  };

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
        tr: ['action', 'click->zgrid#select'],
      },
    });
    this.previouslySelected = null;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
  }

  connect() {
    this.element.replaceChildren();
    let quiz_id = this.quizIdValue;
    let csrf = this.csrf;
    let onclick = function (col, row, col_name, data) {
      Data.setQuestion(csrf, quiz_id, data['id']);
    };
    this.zgrid.reconfigure({
      parent: this.element,
      onClick: onclick,
    });
    this.refresh();
  }

  refresh() {
    Data.getQuestions(this.quizIdValue).then((questions) => {
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
    });
  }

  select(event) {
    if (this.previouslySelected !== null) {
      this.previouslySelected.classList.remove('active_question');
    }
    event.currentTarget.classList.add('active_question');
    this.previouslySelected = event.currentTarget;
  }
}
