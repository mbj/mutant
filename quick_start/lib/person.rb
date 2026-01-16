# frozen_string_literal: true

class Person
  def initialize(age:)
    @age = age
  end

  def adult?
    @age >= 18
  end
end
