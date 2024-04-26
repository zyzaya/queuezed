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
    });
  }

  connect() {
    this.refresh();
  }

  refresh() {
    this.element.replaceChildren();
    this.zgrid.reconfigure({
      parent: this.element,
    });
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
}
