# TODO Issues
- #27 - inconsistently when transitioning from homepage to quiz edit page using Edit button, the layout of the edit page is incorrect: the width of the question is 100% instead of 50% 
- #55 - deleting a question, then undoing that deletion causes the question to be readded at the end of the list instead of where it previously was
---
- #112 - make fonts consistent across browsers 
- #113 - mobile ui on small screens overflows width when zGrid page info is long enough.
  - swap Settings, Sign Out, buttons for icons
  - swap Previous, Next text to icons
  - swap New Question, Undo, Reod, Save to icons
  - add margins to settings page
  - allow settings page textboxes to be smaller
  - remove label for 'delete my account'
- #114 - unsaved changes popup doesn't appear when changes pages with buttons in edit mode
- #115 - unsaved changes popup doesn't appear on mobile
- #118 - 

# Fixed Issues
- #1 - deleting an answer of a related question (of the focused question), and then undoing the deletion causes the answer to be added to the focused question - instead of the related question.
- #3 - adding a new answer is not saved. To reproduce: add answer, click save, reload page.
- #4 - deleting an answer is not saved. To reproduce: delete answer, click save, reload page.
- #5 - cannot undo editing the editing of a question's answers
- #6 - fix navigation breaking javascript: modify javascript to use stimulus
- #10 - clicking the header of zgrid causes an error
- #11 - sorting or filtering zgrid breaks question selection.
- #8 - modifications to a question aren't maintained when switching selection. Modify a question, switch questions, then switch back. The modifications made will have been lost.
- #9 - selection indication is lost when filtering or sorting zgrid
- #13 - editing the content of a question with at least one answer, switching selectiong, then switching back to the edited question causes an error.
- #2 - modifying a question, switching to another question, then undoing the original action causes an error
- #14 - deleting question is not properly reselecting
- #7 - cannot undo the creation of a new question
- #12 - undoing a new question action, when there is no previously selected question, doesn't clear the question edit frame
- #17 - undo is completely broken when modified a related question.
- #16 - resizing columns is broken - possibly due to issue in zgrid
- #15 - inconsistently when refreshing the following error occurs: 
Error: Missing "data-controller=edit" attribute on outlet element for "zgrid" controller 
- #18 - new question is causing 404 not found error
- #20 - question edits aren't reflected in zgrid (add/removing/creating tags, editing content)
- #21 - reconfiguring zgrid loses selection
- #22 - changing quiz title is no longer part of undo/redo
- #24 - redo fails in the following situation: 
  Causes TypeError:
    1. edit question content -> undo -> switch selection -> redo
    2. edit related question content -> undo -> switch selection -> redo
    3. add answer -> undo -> switch selection -> redo
    4. add answer to related -> undo -> switch selection -> redo
    5. modify answer -> undo -> switch selection -> redo
  No error, but isn't switching selection properly (and if it was it would probably throw a TypeError):
    1. delete answer -> undo -> switch selection -> redo
    2. delete answer related -> undo -> switch selection -> redo
    3. delete tag -> undo -> switch selection -> redo
  adds the tag to the selected question instead of the question it was originally added to
    1. add tag -> undo -> switch selection -> redo
    2. create tag -> undo -> switch selection -> redo
- #25 - saving fails in the following situations:
  Doesn't save at all
    1. edit quiz title
  The changes of the undo doesn't persist
    1. add answer -> save -> undo -> save
    2. add answer related -> save -> undo -> save
    3. add tag -> save -> undo -> save
    4. delete tag -> save -> undo -> save
    5. create tag -> save -> undo -> save
  Causes answers to duplicate
    1. modify answer content -> save
- #23 - undoing new question doesn't reset selection.
- #30 - feedback page breaks when a quiz contains related questions
- #29 - by inputting the url directly (http://localhost:3000/quizzes/1/practice/3/answers/new) its possible to access the feedback page even if the user is not logged in. This is true for most routes.
- #26 - question count in quiz subtitle doesn't update with added/removed questions.
- #28 - a question with no answers and no question (aka a newly created question) causes an error when submitting in a practice session
- #31 - create, and editing the content of a new answer causes a server error
- #32 - change button styling so it doesn't change the size of its container
- #38 - console error when trying to filter questions in edit:
  Error invoking action "filter:updateFilter@window->zgrid#updateFilter"
  TypeError: Cannot read properties of undefined (reading 'length')
- #34 - front page question count of quizzes is incorrect
- #37 - sorting by current/best streak in edit is reversed
- #41 - 0 values (for longest streak, etc)  in edit table aren't displayed 
- #46 - when first loading a quiz, placeholder text is shown in question edit frame (first question should be displayed, or nothing if there are not questions)
- #43 - when creating a new answer, the new answer should get focus. similarly when creating a new question, question content should get focus.
- #48 - filter by tag selection should reset to "Select to Add" after adding a tag filter Same with Add Tag
- #44 - the hover border in quiz edit table shouldn't change the size of the element
- #35 - long answers in immediate feedback become partially obscured
- #45 - table content value isn't updated in the following circumstance: create new question -> edit content -> create new question without leaving content text area
- #51 - selection doesn't change in the following circumstance: create new question -> edit content -> select different question. The content also isn't saved
- #52 - setting the filter in edit is slow. This is (likely) due to stimilus controller connecting/disconnecting. Modify zgrid to hide unused elements instead of completely removing them
- #53 - delete an answer then undoing it places that answer at then end of the display, instead of where it previously was located
- #56 - modifying a questions content isn't updating content in zgrid
- #57 - when deleting a question that is the only question with a specific tag - that tag remains in "Filter by tag" and "Add tag" selects
- #50 - adding a tag to a question is unreasonably slow???????????????this suddenly stopped happening with no changes
- #49 - review tag/ time is not being properly updated
- #42 - difficult tag is being added multiple times (and possibly not being removed)
- #40 - theres an issue with how retaking a practice session interacts with the review tag. currently it ignores it but even if it didn't, what questions are up for review change between the start and end of practicing a quiz. To fix this the retry could be based on the order column instead 
- #36 - continue practice session button is broken
- #33 - setting the filter for a practice session such that there are no valid questions causes a 500 internal server error
- #19 - theres an issue with zgrid.getData() (specifically with rowTargetConnected) where it recalculates data on every call - meaning with a custom filter its looping through the rows n^n times. This might be abled to fixed by caching data in zgrid, or by figuring out a better way to access needed data in queuezed.
- #59 - when undoing delete, difficult tag is lost
- #47 - newly added tag isn't saved in the following circumstance: create tag -> switch question -> add tag -> save. The tag is saved on the initial question, but not any subsequent questions. This is causing an error on the add tag now.
- #58 - selecting a question then changing the sorted order of zgrid causes the displayed selected question (in zgrid) and the displayed in the edit question panel to not match. to reproduce
  1.	select a question
  2.	sort zgrid
  this occurs because the changed order of zgrid doesn't actually change the order of html elements, but the selection is unaware of this.
- #60 - modifying question content doesn't update add related option 
- #39 - when going to edit page, the same get request happens twice
- #62 - creating a new tag, with early alphabetical sorting, puts it prior to Difficult, Review tags in filter by tag select
- #61 - the flash is showing twice
- #64 - modify question display to allow for not having a question / make initial question edit detail display hidden 
- #63 - fix form id console warnings
- #65 - tag saving is broken.
- #66 - continue practice button is broken
- #67 - immediate feedback ends up with duplicate single question feedbacks in the following situation:
  1. submit an answer to  question
  2. on immediate feedback page, refresh
  3. reanswer question
- #68 - new quiz button doesn't work 
- #69 - modifying a title doesn't trigger unsaved changes indicator
- #75 - creating a new question doesn't focus content textarea
- #74 - creating a new question should change page to the final page.
- #81 - doing the following immediately after load causes a console error: new question -> undo
- #71 - order questions by created_at when retrieving them to fill zgrid
- #77 - retry doesn't obey difficult filter (and possibly review filter?)
- #80 - filtering when on the last page causes a console error
- #76 - in immediate feedback, a question with longer content shouldn't be multi line when there is still space available
- #79 - modify saving such that if any part fails server side, no changes are made to the db, no changes occur client side, and an error message is shown in the flash
- #73 - add related question select is only showing displayed questions - even if Limit to displayed questions is unchecked (this seems to happen after adding a new question)
- #70 - creating a new tag and adding it to multiple questions duplicates that tag by as many times as it was added to questions.
- #83 - can't type spaces in an answer
- #84 - deleting the last question of a quiz should set question display to none 
- #85 - deleting two tags in a row  causes a console error
- #82 - unsaved indicator isn't correct after saving:
  1. make changes
  2. save
  3. undo / redo
- #87 - tags are being duplicated. This occurs when adding a newly created tag to additional questions. It happens when the new tag is added to at least 3 questions, the tag ends up being added n - 1, where n is the number of questions the tag is added to.
- #86 - adding a relation to a newly created question (possibly if the relation is a new question) fails to save properly
- #90 - create new question -> create and add new tag -> delete that tag. Causes a failed save.
- #89 - deleting a question doesn't remove that question as a relation from other questions
- #91 - deleting a question, then undoing, then modifying the originallly deleted question, then saving, doesn't properly save the question
- #88 - deleting a question isn't properly changing question detail selection??
- #92 - a long quiz title in edit should utilize the full page width
- #93 - reivew tag isn't being updating immediately
- #94 - reduce databse calls in quiz saving
- #97 - fix forgot password view
- #98 - change password view
- #99 - fix deleting account
- #100 - deleting a question and then selecting a different question that had the deleted question as a relation causes an null reference error in console.
- #101 - the following fails to save properly: delete question -> save -> undo -> modify that questions content -> save
- #95 - when a the page is changed after creating a new question add relation select isn't properly updated (when set ti limit to shown questions)
- #96 - review count in edit isn't updated when adding / removing questions 
- #102 - change error colour in sign up page to be darker red
- #103 - fix how error is displayed in forgot pasword page when not entering an email / entering an invalid email 
- #104 - fix how errors are displayin in settings page
- #105 - remove back button in settings page
- #106 - disable suggestions from quiz title edit
- #107 - rename toolbar names (undo, redo, new q, save)
- #108 - next review of a newly create question is set to "Invalid Date"
- #109 - refine practice/new view
- #110 - the following causes a console error (Cannot read properties of undefined): select a question -> set tag filter (such that the selected question is still displayed) -> delete question
- #111 - review button isn't enabled properly. There's an issue with how review is updated - it only updates when an ActiveRecord object is instantiated. This means that SQL queries (such as .where) don't update the review/next_review columns.
- #72 - look into improving performance / reducing database calls when saving a quiz, specifically when creating new records
- #78 - look into improving performance when loading questions into zgrid
- #54 - selecting an question as soon as it loods causing js error: 
- #116 - when the save buttons text has an asterisk (there are unsaved changes), it is not capitalized
- #117 - Mastered questions are considered as review when on Edit page, but not on home page or when creating a practice quiz.