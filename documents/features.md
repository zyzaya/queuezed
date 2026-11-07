# TODO Features
- #3 - improve question list table:
  - #5 - add ability to choose which columns are visible
  - #53 - redo how columns are divided, make it more intelligent for content
- #12 - add ability to minimize related questions in question edit
- #17 - advanced filter (see qz and advanced filter mockup)
- #27 - add ability to change what proportion of the page the question list and question edit take up
- #35 - when transition directly from edit to practice, maintain filters.
- #56 - Add automatic tooling. (new projects in Rails 7 have these by default - look to new app for examples)
  - dependabot: a github tool that automatically detects and alerts for vulnerabilities, security updates, and version updates.
  - brakemen: an analysis tool the checks rails for security vulnerabilities
  - rubocop: lints ruby code
  - importmap/audit: scan for security vulnerabilities in javascript dependencies
  - automatic testing: rewrite tests (especially system tests) to not be occasionally inconsistent
---
- #58 - complete redo of ui design
- #59 - add ability dropdown/selections to zGrid to show/hide columns
- #60 - refine zGrid (and other) margins/padding such that there is less white space
- #61 - rewrite client side modifications of quiz to be stored in a proper file format (JSON, probably), and to automatically store locally when changes are made
- #62 - add anonymous users - allowing a user to temporarily create, edit, and practice quizzes. To allow a user to experiment with functionality without having to sign up.
 Full Functional guest user: technically more difficult (especially since it wasn't built with this in mind from the beginning), increasing db complexity and storage size.
 Limited functionality: easy to do with edit (no saving, practicing)

- #63 - add settings page - changing fonts, styles, how quizzes are presented
- #64 - add statistics page to display detailed information about how well the user does when answering questions and practicing quizzes
- #65 - update rails
- #66 - 

# Completed Features
- #57 - consider lowering the storage of the database from 15gb to either 1gb or 5gb.
  to do so:
  1. backup current db
  2. create new db (with lower disk size)
  3. load backup into new db
- #3 - improve question list table:
- #4 - add ability to filter visible questions by text
- #6 - add ability to sort ascending/descending by column
- #7 - adjustable columns
- #15 - add ability to filter visible questions by tag
- #2 - make title of a quiz editable while in edit
- #9 - add way to get home from edit page
- #13 - ability to add tags to questions 
- #10 - add transition from home page to taking a quiz
- #11 - add transition from edit page to taking a quiz
- #18 - Improve Feedback view to provide information more clearly and intuitively
- #20 - Enter key in immediate feedback should be equivalent of clicking next buttons
- #19 - Enter key in multi-answer questions should move to next answer box (unless of final answer box) instead of immediately submitting
- #24 - implement new quiz button
- #25 - add ability to edit quiz title from homepage 
- #26 - add ability to practice only filtered questions
- #21 - SRS functionality
- #22 - difficult and review quiz functionality
- #8 - add ability to add or remove related questions from currently visible question
- #34 - make client side question modification function the same way the other modifications work - making server requests was due to the previously more complex database organization. Remove SoftDestroyable.
  1. automatically visually split answer variants when editing an answer
- #32 - add x / total questions displayed to edit page
- #30 - in edit, the question table should have its own scrollbar 
- #23 - keyboard shortcuts:
  1. ctrl+s -> save
  2. ctrl+z -> undo
  3. ctrl+shift+z -> redo
  4. alt+p  -> practice
  5. alt+q -> new question
  6. alt+shift+q  -> delete (focused) question
  7. alt+a -> add answer to focused question
  8. alt+shift+a -> delete (focused) answer
  9. alt+t -> focus create tag
  10. alt+k -> focus filter
- #31 - add indicator for if there is unsaved changes
- #28 - add ability to limit the number of questions taken
- #29 - add ability to remove partially completed practice sessions.
- #36 - additional keyboard shortcuts:
alt + p -> practice
alt + > -> select next question
alt + < -> select previous question
- #37 - deal with quizzes with many questions
 figure out how to best get a scroll bar just on the table
fix n+1 error when saving quiz.
fix zgrid pagination styling
- #38 - implement review/difficult shortcut buttons on main page
- #33 - mobile interface 
- #41 - filter by text should be searching answers in addition to content
- #42 - consider modifying filter by text to live update, instead of only on enter
- #40 - are relationships supposed to be bidirectional? setting b as a relation to a will be a a relation to b?
- #44 - add edit quiz button to practice
- #47 - add alt-s as keyboart shortcut for saving
- #43 - add statistics to question detail view
- #45 - consider  adding statistics to feedback page - decided against. it adds an excess amount of information to the feedback page.
- #46 - improve difficult / review shortcuts: add (#) for number of questions, and disable button if zero 
- #39 - add burning of items that go past final srs stage?
- #48 - allow for the changing of a users password
- #49 - allow a user to delete their account
- #50 - password recovery
- #51 - remove references to nested attributes in models
- #52 - make a pass of html and css to tidy up.
- #54 - add messages to all assertions
- #55 - change favicon
- #51 - email confirmation on sign up: decided against for now
