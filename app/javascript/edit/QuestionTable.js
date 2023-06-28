import { Grid } from 'gridjs';

const QuestionTable = (parent, quiz_id) => {
  let grid = new Grid({
    columns: ['Question', 'Streak', 'Best Streak'],
    server: {
      url: `/quizzes/${quiz_id}/questions`,
      then: (questions) =>
        questions.map((q) => [q.content, q.current_streak, q.longest_streak]),
    },
    search: true,
    sort: true,
    resizable: true,
    style: {
      container: {
        'background-color': 'var(--tertiary-bg-color-dark)',
        color: 'var(--main-text-color)',
      },
      table: {},
      td: {
        'background-color': 'none',
        border: 'none',
        color: 'var(--main-text-color)',
        'white-space': 'nowrap',
        overflow: 'hidden',
        'text-overflow': 'ellipsis',
        'text-decoration': 'none',
        padding: '8px 3px',
      },
      th: {
        'white-space': 'nowrap',
        border: 'none',
        'background-color': 'var(--tertiary-bg-color-dark)',
        color: 'var(--main-text-color)',
        'font-size': 'large',
        'border-bottom': '4px solid var(--secondary-bg-color-dark)',
        'border-radius': '0',
        padding: '4px',
        margin: '0 4px',
      },
      header: {},
      footer: {},
    },
  });

  grid.render(parent);

  return {};
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
