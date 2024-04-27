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
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
  }

  connect() {
    this.element.replaceChildren();
    this.zgrid.reconfigure({
      parent: this.element,
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
      let body = document.getElementsByClassName('zgrid_body');
      if (body.length === 1) {
        let grid_data = this.zgrid.getData();
        body = body[0];
        console.log(body.children);
        Array.from(body.children).forEach((r, i) => {
          r.dataset['questionIdValue'] = grid_data[i].id;
        });
      }
    });
  }

  select(event) {
    if (this.previouslySelected !== null) {
      this.previouslySelected.classList.remove('active_question');
    }
    event.currentTarget.classList.add('active_question');
    this.previouslySelected = event.currentTarget;
    Data.setQuestion(
      this.csrf,
      this.quizIdValue,
      event.currentTarget.dataset.questionIdValue
    );
  }
}
