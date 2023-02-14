# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

user = User.new(email: 'username@test.ca', password: 'password')
quiz1 = user.quizzes.new(name: 'Language')
srs1 = SrsBox.new(rank: 1)
0.upto(10) do
  content = Faker::Name.first_name
  correct = content.reverse
  a = Answer.new
  a.answer_variants.new(content: correct)
  a.answer_variants.new(content: correct.upcase)
  a.answer_variants.new(content: correct.downcase)
  q = Question.new(content: "Reverse of: #{content}")
  q.answers << a
  srs1.questions << q
  quiz1.srs_boxes << srs1
end
user.quizzes << quiz1

# quiz2 = user.quizzes.new(name: 'Harry Potter')
# 0.upto(10) do
#   content = Faker::Movies::HarryPotter.character
#   # q = Question.new(content: content)
#   3.upto(rand(3..6)) do |n|
#     correct = content.slice(0, n)
#     answer = Answer.new(content: "First #{"#{n} " if n > 1}character#{'s' if n > 1}")
#     answer.answer_variants.new(content: correct)
#     answer.answer_variants.new(content: correct.upcase)
#     answer.answer_variants.new(content: correct.downcase)
#     q.answers << answer
#   end
#   srs = SrsBox.new(rank: 1)
#   srs.questions << q
#   quiz2.srs_boxes << srs
# end

quiz3 = user.quizzes.new(name: 'This is a quiz with an extremely long name to test how the web layout looks like')

0.upto(10) do |n|
  user.quizzes.new(name: "quiz ##{n}")
end

user.save
