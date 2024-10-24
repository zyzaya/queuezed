import AnswerDisplay from './AnswerDisplay';

export default function SingleQuestionDisplay(
  id,
  content,
  answers,
  related = false
) {
  let container = document.createElement('div');
  container.classList.add('single_question_edit');
  container.dataset.action =
    'edit:questionContentChange@window->edit--single-question#setContent';
  container.dataset['controller'] = 'edit--single-question';
  container.dataset['editTarget'] = 'singleQuestionContainer';
  container.dataset['edit-QuestionTarget'] = 'singleQuestionContainer';
  container.dataset['edit-SingleQuestionEdit-ZgridOutlet'] = '.edit_list';
  container.dataset['edit-SingleQuestionIdValue'] = id;
  let header = document.createElement('div');
  header.classList.add('question_header');
  header.innerHTML = 'Question.';
  container.appendChild(header);
  if (related) {
    let remove_as_related = document.createElement('button');
    remove_as_related.classList.add('button');
    remove_as_related.classList.add('remove_as_related');
    remove_as_related.innerText = 'Remove from related';
    remove_as_related.dataset['action'] =
      'edit--single-question#removeAsRelation';
    header.appendChild(remove_as_related);
  }
  let question_content = document.createElement('textarea');
  question_content.classList.add('question_content');
  question_content.dataset['editTarget'] = 'questionContent';
  question_content.dataset['edit-SingleQuestionIdValue'] = id;
  question_content.dataset['edit-SingleQuestionTarget'] = 'info';
  question_content.dataset['action'] =
    'edit--single-question#questionContentChange';
  question_content.value = content;
  container.appendChild(question_content);
  let answers_header = document.createElement('div');
  answers_header.classList.add('answers_header');
  container.appendChild(answers_header);
  let add_answer = document.createElement('a');
  add_answer.classList.add('button');
  add_answer.classList.add('add_answer');
  add_answer.dataset['action'] = 'edit--single-question#addAnswer';
  add_answer.innerHTML = 'Add Answer';
  container.appendChild(add_answer);
  answers.forEach((a) => AnswerDisplay(container, id, a.id, a.content));
  return container;
}
