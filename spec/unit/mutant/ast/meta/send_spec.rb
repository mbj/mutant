# frozen_string_literal: true

RSpec.describe Mutant::AST::Meta::Send do
  let(:object) { described_class.new(node) }

  def parse(source)
    Unparser.parse(source)
  end

  let(:method_call)            { parse('foo.bar(baz)')  }
  let(:attribute_read)         { parse('foo.bar')       }
  let(:attribute_assignment)   { parse('foo.bar = baz') }
  let(:binary_method_operator) { parse('foo == bar')    }

  class Expectation
    include Adamantium, Anima.new(:name, :attribute_assignment, :binary_method_operator)

    ALL = [
      [:method_call,            false, false],
      [:attribute_read,         false, false],
      [:attribute_assignment,   true,  false],
      [:binary_method_operator, false, true]
    ].map do |values|
      new(Hash[anima.attribute_names.zip(values)])
    end.freeze
  end # Expectation

  # Rspec should have a build in for this kind of "n-dimensional assertion with context"
  (Expectation.anima.attribute_names - %i[name]).each do |name|
    describe "##{name}?" do
      subject { object.public_send(:"#{name}?") }

      Expectation::ALL.each do |expectation|
        context "on #{expectation.name}" do
          let(:node) { public_send(expectation.name) }

          it { should be(expectation.public_send(name)) }
        end
      end
    end
  end
end
