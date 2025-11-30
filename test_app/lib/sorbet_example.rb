# typed: true

class SorbetExample
  extend T::Sig

  sig { params(x: Integer, y: Integer).returns(Integer) }
  def add(x, y)
    x + y
  end

  sig { params(x: Integer).returns(String) }
  def double_as_string(x)
    (x * 2).to_s
  end

  sig { params(name: String).returns(String) }
  def greet(name)
    "Hello, #{name}!"
  end
end
