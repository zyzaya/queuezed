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
tags1 = ['a', 'b', 'c']
0.upto(10) do |i|
  content = Faker::Name.first_name
  correct = content.reverse
  a = Answer.new
  a.answer_variants.new(content: correct)
  a.answer_variants.new(content: correct.upcase)
  a.answer_variants.new(content: correct.downcase)
  q = Question.new(content: "Reverse of: #{content}")
  tags1.each do |t|
    if correct.downcase.include?(t)
      tag = Tag.find_or_create_by(content: "#{t}")
      q.tags << tag
    end
  end
  if i == 0
    0.upto(15) do 
      q.tags << Tag.find_or_create_by(content: Faker::Name.first_name)
    end
  end
  q.answers << a
  srs1.questions << q
  
end
quiz1.srs_boxes << srs1
user.quizzes << quiz1

quiz2 = user.quizzes.new(name: 'Harry Potter')
srs2 = SrsBox.new(rank: 1)
0.upto(10) do
  content = Faker::Movies::HarryPotter.character
  tag = Tag.new(content: content)
  related = []
  3.upto(rand(3..6)) do |n|
    q = Question.new(content: "First #{"#{n} " if n > 1}character#{'s' if n > 1} of #{content}")
    t = Tag.find_or_create_by(content: "#{n}")
    q.tags << tag
    q.tags << t
    correct = content.slice(0, n)
    0.upto(rand(0..1)) do
      answer = Answer.new
      answer.answer_variants.new(content: correct)
      answer.answer_variants.new(content: correct.upcase)
      answer.answer_variants.new(content: correct.downcase)
      q.answers << answer
    end
    
    srs2.questions << q
    related << q
  end
  related.each do |q|
    related.each do |r|
      q.relations << r unless q == r
    end
  end
end
quiz2.srs_boxes << srs2

quiz3 = user.quizzes.new(name: 'This is a quiz with an extremely long name to test how the web layout looks like')

0.upto(10) do |n|
  user.quizzes.new(name: "quiz ##{n}")
end

user.save
