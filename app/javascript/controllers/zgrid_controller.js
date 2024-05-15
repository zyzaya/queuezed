import { Controller } from '@hotwired/stimulus';
import { zGrid } from 'zGrid';
import Data from 'edit/Data';
import Undo from 'edit/Undo';
import Change from 'edit/Change';
import ID from 'edit/ID';
import AnswerDisplay from '../edit/AnswerDisplay';
import TagFilterDisplay from '../edit/TagFilterDisplay';

export default class extends Controller {
  static values = {
    quizId: String,
    previouslySelected: String,
  };

  static targets = [
    'body',
    'row',
    'zgridContainer',
    'tagFilterOption',
    'tagFilterList',
    'tagFilter',
  ];
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
        td: 'zg_td',
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

  editOutletConnected(outlet, element) {
    element.dataset.editCurrentlySelectedValue = this.currentlySelected;
  }

  rowTargetConnected(element) {
    element.dataset.action = 'click->edit#select';
    let nodes = element.parentNode.children.length;
    let grid_data = this.zgrid.getData();
    if (nodes === grid_data.length) {
      let index = Array.from(element.parentNode.children).findIndex(
        (e) => e === element
      );
      let id = grid_data[index].id;
      element.dataset.questionIdValue = id;
      element.dataset.editQuestionIdParam = id;
      if (this.currentlySelected === id)
        element.classList.add('active_question');
    }
  }

  zgridContainerTargetConnected(element) {
    element.replaceChildren();
    this.zgrid.reconfigure({
      parent: element,
      columns: [
        {
          id: 'id',
          visible: true,
        },
        {
          id: 'tags',
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
      searchbox: false,
    });
    this.refresh();
  }

  refresh(event) {
    return Data.getQuestions(this.quizIdValue)
      .then((questions) => {
        let data = questions.map((e) => {
          let tags = e.tags.reduce((a, c) => (a += ` ${c.id}`), '');
          return {
            id: e.id.toString(),
            content: e.content,
            current_streak: e.current_streak,
            longest_streak: e.longest_streak,
            tags: tags,
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
    this.setSelectedQuestion(event.detail.questionId);
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
      this.currentlySelected = id;
      this.editOutlet.element.dataset.editCurrentlySelectedValue = id;
      element.classList.add('active_question');
      element.dataset.editPreviouslySelectedParam = this.previouslySelected;
      Data.setQuestion(this.csrf, this.quizIdValue, id);
    }
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

  hasTagFilter(id, content) {
    let existing = this.tagFilterTargets.find((t) => {
      return (
        t.dataset.questionTagIdValue.toString() === id.toString() &&
        t.text === content
      );
    });
    return existing !== undefined;
  }

  addTagFilter(event) {
    let tagId = event.currentTarget.value;
    if (tagId === -1) return;
    let content = this.tagFilterOptionTargets.find((t) => t.value === tagId);
    content = content.text;

    if (this.hasTagFilter(tagId, content)) return;

    let tag = TagFilterDisplay(tagId, content);
    this.tagFilterListTarget.appendChild(tag);

    let filter = this.tagFilterTargets.map((t) => t.dataset.questionTagIdValue);
    this.zgrid.reconfigure({
      filter: (row) => {
        let tags = row.tags.split(' ');
        return filter.some((f) => tags.includes(f));
      },
    });
  }
}
