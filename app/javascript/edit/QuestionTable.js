import { zGrid } from 'zGrid';

const QuestionTable = (parent, quiz_id) => {
  let obj = {};
  let grid = new zGrid({
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
  });
  // let grid = new Grid({
  //   columns: [
  //     {
  //       name: 'id',
  //       hidden: true,
  //       attributes: (cell, row) => {
  //         if (row) return { 'data-question_id': row.cells[0].data };
  //       },
  //     },
  //     {
  //       name: 'Question',
  //       attributes: (cell, row) => {
  //         if (row) return { 'data-question_id': row.cells[0].data };
  //       },
  //     },
  //     {
  //       name: 'Streak',
  //       attributes: (cell, row) => {
  //         if (row) return { 'data-question_id': row.cells[0].data };
  //       },
  //     },
  //     {
  //       name: 'Best Streak',
  //       attributes: (cell, row) => {
  //         if (row) return { 'data-question_id': row.cells[0].data };
  //       },
  //     },
  //   ],
  //   server: {
  //     url: `/quizzes/${quiz_id}/questions`,
  //     then: (questions) =>
  //       questions.map((q) => [
  //         q.id,
  //         q.content,
  //         q.current_streak,
  //         q.longest_streak,
  //       ]),
  //   },
  //   search: true,
  //   sort: true,
  //   resizable: true,
  //   style: {
  //     container: {
  //       'background-color': 'var(--tertiary-bg-color-dark)',
  //       color: 'var(--main-text-color)',
  //     },
  //     table: {},
  //     td: {
  //       'background-color': 'none',
  //       border: 'none',
  //       color: 'var(--main-text-color)',
  //       'white-space': 'nowrap',
  //       overflow: 'hidden',
  //       'text-overflow': 'ellipsis',
  //       'text-decoration': 'none',
  //       padding: '8px 3px',
  //     },
  //     th: {
  //       'white-space': 'nowrap',
  //       border: 'none',
  //       'background-color': 'var(--tertiary-bg-color-dark)',
  //       color: 'var(--main-text-color)',
  //       'font-size': 'large',
  //       'border-bottom': '4px solid var(--secondary-bg-color-dark)',
  //       'border-radius': '0',
  //       padding: '4px',
  //       margin: '0 4px',
  //     },
  //     header: {},
  //     footer: {},
  //   },
  // });

  // grid.on('rowClick', (event, data) => {
  //   if (obj.onRowClick !== null) {
  //     obj.onRowClick(event, data);
  //   }
  // });
  // console.log(grid);
  // obj.render = function () {
  //   grid.render(parent);
  // };

  // obj.forceRender = function () {
  //   grid.forceRender();
  // };

  obj.forceRender = function () {
    fetch(`/quizzes/${quiz_id}/questions`)
      .then((response) => response.json())
      .then((questions) => {
        console.log(questions);
        let data = questions.map((e) => {
          return {
            id: e.id === null ? 0 : e.id.toString(),
            content: e.content,
            current_streak: e.current_streak,
            longest_streak: e.longest_streak,
          };
        });
        console.log(data);
        grid.reconfigure({
          data: data,
        });
      });
  };

  obj.render = function () {
    obj.forceRender();
  };

  return obj;
};

export default QuestionTable;

/* <table class="question_list" id="question_list">
<tr class="list_header">
  <th>Question</th>
  <th>Streak</th>
  <th>Best Streak</th>
</tr>
<% @quiz.questions.each do |q| %>
  <tr class="list_row" data-question_id= <%= q.id %>>
    <td><%= "#{q.content}"%></td>
    <td><%= "#{q.current_streak}0"%></td>
    <td><%= "#{q.longest_streak}0"%></td>
  </tr>
<% end %>
</table> */
