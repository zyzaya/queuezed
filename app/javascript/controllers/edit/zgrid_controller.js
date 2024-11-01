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

  static targets = ['zgridContainer', 'questionCount'];
  static outlets = ['edit'];

  initialize() {
    let parent = document.createElement('div');

    this.zgrid = new zGrid({
      parent: parent,
      data: [],
      columns: [{ id: 'id', visible: false }],
      className: {
        table: 'zg_table',
        th: 'zg_th',
        tbody: 'zg_body',
        tr: 'zg_row',
        td: 'zg_td',
        selected: 'active_question',
      },
      onClick: (col, row, colName, data) => this.setSelectedQuestion(data.id),
    });
    this.currentlySelected = null;
    this.csrf = document.head.querySelector('meta[name=csrf-token]')?.content;
    this.questions = [];
  }

  editOutletConnected(outlet, element) {
    element.dataset.editCurrentlySelectedValue = this.currentlySelected;
    this.refresh().then(() => {
      this.dispatch('updateQuestionList', {
        detail: { data: this.zgrid.getData() },
      });
    });
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
          id: 'tags',
          visible: false,
        },
        {
          id: 'content',
          name: 'Question',
        },
        {
          id: 'review',
          visible: false,
        },
        {
          id: 'difficult',
          visible: false,
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
  }

  refresh(event) {
    let tagCount = {};
    let changes = [];
    if (event !== undefined && event.detail.changes !== undefined) {
      changes = event.detail.changes;
    }

    return Change.LoadQuestions(this.quizIdValue)
      .then((questions) => {
        this.questions = questions;
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
            difficult: e.difficult,
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
        this.updateQuestionTotal();
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
    this.setSelectedQuestion(event.detail.id);
  }

  setSelectedQuestion(id) {
    if (id === this.currentlySelected || id === 'null' || id === undefined)
      return;

    this.zgrid.setSelected(id);
    this.currentlySelected = id;
    this.editOutlet.currentlySelectedValue = id;
    // displayed question
    let question = Change.GetQuestion(id);
    if (question === undefined) return;
    let relations = question.relations.map((e) => {
      let r = this.questions.find((q) => q.id == e.id);
      return {
        id: e.id,
        content: r.content,
        answers: r.answers,
      };
    });
    this.dispatch('setQuestion', {
      detail: {
        id: question.id,
        content: question.content,
        tags: question.tags,
        answers: question.answers,
        relations: relations,
      },
    });
  }

  setSelectedToSibling() {
    let id = this.currentlySelected;
    let data = this.zgrid.getData();
    let current = data.findIndex((e) => e.id == id);
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
    let { tag, text, review, difficult } = event.detail;

    this.zgrid.reconfigure({
      filter: (row) => {
        let tags = row.tags.split(' ');
        let matches_text_filter =
          text === '' || row.content.toLowerCase().includes(text);
        let matches_tag_filter =
          tag.length === 0 || tag.some((f) => tags.includes(f));
        let matches_review_filter = !review || row.review === 'true';
        let matches_difficult_filter = !difficult || row.difficult === 'true';
        return (
          matches_text_filter &&
          matches_tag_filter &&
          matches_review_filter &&
          matches_difficult_filter
        );
      },
    });

    this.updateQuestionTotal();
    this.dispatch('updateFilteredQuestionList', {
      detail: { data: this.zgrid.getData() },
    });
  }

  // local question modifications
  addTag(event) {
    let { question_id, tag_id } = event.detail;
    let question = this.zgrid.getRow(question_id);
    question.tags += ` ${tag_id}`;
    this.zgrid.setRow(question_id, question);
  }

  removeTag(event) {
    let { question_id, tag_id } = event.detail;
    let question = this.zgrid.getRow(question_id);
    question.tags = question.tags.split(' ').filter((t) => t !== tag_id);
    this.zgrid.setRow(question_id, question);
  }

  addQuestion(event) {
    let question = Change.GetQuestion(event.detail.id);
    if (question === undefined) this.zgrid.addRow({ id: event.detail.id });
    else {
      let tags = question.tags.join(' ');
      this.zgrid.addRow({
        id: event.detail.id.toString(),
        review: question.review,
        tags: tags,
        difficult: question.difficult,
        content: question.content,
        current_streak: question.current_streak,
        longest_streak: question.longest_streak,
        times_taken: question.times_taken,
        times_correct: question.times_correct,
      });
    }
    this.updateQuestionTotal();
  }

  deleteQuestion(event) {
    this.zgrid.removeRow(event.detail.id);
    this.updateQuestionTotal();
  }

  questionContentChange(event) {
    let { id, content } = event.detail;
    let question = this.zgrid.getRow(id);
    question.content = content;
    this.zgrid.setRow(id, question);
    this.dispatch('updateQuestionList', {
      detail: { data: this.zgrid.getData() },
    });
  }

  updateQuestionTotal() {
    let displayed = this.zgrid.getData().length;
    let total = this.zgrid.getRawData().length;
    this.questionCountTarget.innerText = `${displayed} / ${total} questions`;
  }
}
