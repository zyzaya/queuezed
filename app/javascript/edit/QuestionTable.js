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
  });

  grid.render(parent);

  return {};
};

export default QuestionTable;
