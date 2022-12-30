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
0.upto(10) do
  content = Faker::Name.first_name
  correct = content.reverse
  a = Answer.new(content: 'Reverse')
  a.answer_variants.new(content: correct)
  q = Question.new(content: content)
  q.answers << a
  srs = SrsBox.new(rank: 1)
  srs.questions << q
  quiz1.srs_boxes << srs
end
user.quizzes << quiz1

quiz2 = user.quizzes.new(name: 'HP')
0.upto(10) do
  content = Faker::Movies::HarryPotter.character
  q = Question.new(content: content)
  3.upto(rand(3..6)) do |n|
    correct = content.slice(0, n)
    answer = Answer.new(content: "First #{"#{n} " if n > 1}character#{'s' if n > 1}")
    answer.answer_variants.new(content: correct)
    answer.answer_variants.new(content: correct.upcase)
    answer.answer_variants.new(content: correct.downcase)
    q.answers << answer
  end
  srs = SrsBox.new(rank: 1)
  srs.questions << q
  quiz2.srs_boxes << srs
end

user.save
