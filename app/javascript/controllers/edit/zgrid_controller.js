import { Controller } from '@hotwired/stimulus';
import { zGrid } from 'zGrid';
import Data from 'edit/Data';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import ID from 'edit/ID';
import AnswerDisplay from '../../display/AnswerDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
  };

  static targets = ['zgridContainer'];
  static outlets = ['edit'];

  initialize() {
    let parent = document.createElement('div');

    this.zgrid = new zGrid({
      parent: parent,
      data: [],
      columns: ['id'],
      className: {
        table: 'zg_table',
        th: 'zg_th',
        tbody: 'zg_body',
        tr: 'zg_row',
        td: 'zg_td',
      },
      onClick: (col, row, colName, data) => this.setSelectedQuestion(data.id),
    });
    this.currentlySelected = null;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.change_handler = Change(this.csrf, this.quizIdValue);
  }

  editOutletConnected(outlet, element) {
    element.dataset.editCurrentlySelectedValue = this.currentlySelected;
  }

  zgridContainerTargetConnected(element) {
    element.replaceChildren();
    this.zgrid.reconfigure({
      parent: element,
      columns: [
        {
          id: 'id',
          visible: false,
        },
        {
          id: 'review',
          visible: false,
        },
        {
          id: 'tags',
          visible: false,
        },
        {
          id: 'content',
          name: 'Question',
        },
        {
          id: 'current_streak',
          name: 'Current Streak',
        },
        {
          id: 'longest_streak',
          name: 'Longest Streak',
        },
        {
          id: 'times_taken',
          name: 'Times Taken',
        },
        {
          id: 'times_correct',
          name: 'Times Correct',
        },
      ],
      searchbox: false,
    });
    this.refresh();
  }

  refresh(event) {
    let tagCount = {};
    let changes = [];
    if (event !== undefined && event.detail.changes !== undefined) {
      changes = event.detail.changes;
    }

    return Data.getQuestions(this.quizIdValue)
      .then((questions) => {
        let zgrid_data = questions.map((e) => {
          let tags = '';
          e.tags.forEach((t) => {
            tags += ` ${t.id}`;
            tagCount[t.id] =
              tagCount[t.id] === undefined ? 1 : tagCount[t.id] + 1;
          });
          let content = e.content;
          if (changes.questions !== undefined) {
            let c = changes.questions.find((q) => q.id === e.id.toString());
            content = c === undefined ? content : c.content;
          }
          return {
            id: e.id.toString(),
            review: e.review,
            tags: tags,
            content: content,
            current_streak: e.current_streak,
            longest_streak: e.longest_streak,
            times_taken: e.times_taken,
            times_correct: e.times_correct,
          };
        });
        this.dispatch('setTagCount', { detail: { tagCount: tagCount } });
        this.zgrid.reconfigure({ data: zgrid_data });
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
    this.setSelectedQuestion(event.detail.questionId);
  }

  setSelectedQuestion(id) {
    id = id.toString();
    let prev = document.querySelector('.active_question');
    if (prev != null) prev.classList.remove('active_question');
    let children = document.querySelectorAll(
      '.zg_body > .zg_row:not(.zgrid_hidden)'
    );
    let row = this.zgrid.getData().findIndex((e) => e.id === id);
    let curr = children[row];
    curr.classList.add('active_question');
    this.currentlySelected = id;
    this.editOutlet.currentlySelectedValue = id;
    Data.setQuestion(this.csrf, this.quizIdValue, id);
    // dispatch set question, recieved by question controller?
    // tag options (set by quiz load)
    // q tags (set by populate)
    // single question content (set by populate)
    // single question answers (set by populate)
    // relations
    // sq content
    // sq answer
  }

  setSelectedToSibling() {
    let question_id = this.currentlySelected;
    let data = this.zgrid.getData();
    let current = data.findIndex(
      (e) => e.id.toString() === question_id.toString()
    );
    if (current === -1) return;
    if (current + 1 < data.length) {
      let sibling = data[current + 1];
      this.setSelectedQuestion(sibling['id']);
    } else if (current - 1 >= 0) {
      let sibling = data[current - 1];
      this.setSelectedQuestion(sibling['id']);
    }
  }

  updateFilter(event) {
    let tagFilter = event.detail.tagFilter;
    let textFilter = event.detail.textFilter;
    let reviewFilter = event.detail.reviewFilter;

    this.zgrid.reconfigure({
      filter: (row) => {
        let tags = row.tags.split(' ');
        let matches_text_filter =
          textFilter === '' || row.content.toLowerCase().includes(textFilter);
        let matches_tag_filter =
          tagFilter.length === 0 || tagFilter.some((f) => tags.includes(f));
        let matches_review_filter = !reviewFilter || row.review;
        return (
          matches_text_filter && matches_tag_filter && matches_review_filter
        );
      },
    });
  }

  // local question modifications
  addTag(event) {
    let qId = event.detail.questionId;
    let tagId = event.detail.tagId;
    let question = this.zgrid.getRow(qId);
    question.tags += ` ${tagId}`;
    this.zgrid.setRow(qId, question);
  }

  removeTag(event) {
    let qId = event.detail.questionId;
    let tagId = event.detail.tagId;
    let question = this.zgrid.getRow(qId);
    question.tags = question.tags.split(' ').filter((t) => t !== tagId);
    this.zgrid.setRow(qId, question);
  }

  questionContentChange(event) {
    let qId = event.detail.questionId;
    let question = this.zgrid.getRow(qId);
    question.content = event.detail.questionContent;
    this.zgrid.setRow(qId, question);
  }
}
