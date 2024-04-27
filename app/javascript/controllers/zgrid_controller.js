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
    return Data.getQuestions(this.quizIdValue).then((questions) => {
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

  setSelectionQuestion(id) {
    let element = document.querySelector(`[data-question-id-value='${id}']`);
    if (element !== undefined) {
      if (this.previouslySelected !== null) {
        this.previouslySelected.classList.remove('active_question');
      }
      element.classList.add('active_question');
      this.previouslySelected = element;
      Data.setQuestion(this.csrf, this.quizIdValue, id);
    }
  }

  select(event) {
    this.setSelectionQuestion(event.currentTarget.dataset.questionIdValue);
  }

  newQuestion(event) {
    Data.newQuestion(this.csrf, this.quizIdValue).then((question) => {
      this.refresh().then((response) => this.setSelectionQuestion(question.id));
    });
  }

  deleteQuestion(event) {
    console.log('delete question');
  }
}
