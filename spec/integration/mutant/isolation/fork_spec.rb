# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Fork, mutant: false do
  def apply(&block)
    Mutant::Config::DEFAULT.isolation.call(&block)
  end

  it 'isolates local writes' do
    a = 1

    expect { apply { a = 2 } }.to_not(change { a }.from(1))
  end

  it 'captures console output' do
    result = apply do
      $stdout.puts('foo')
      $stderr.puts('bar')
    end

    expect(result.log).to eql("foo\nbar\n")
  end

  it 'allows to read result' do
    result = apply { :foo }

    expect(result.value).to eql(:foo)
  end
end
