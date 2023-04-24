# frozen_string_literal: true

RSpec.describe Mutant::AST::Meta::Send do
  let(:object) { described_class.new(node: node) }

  def parse(source)
    Unparser.parse(source)
  end

  let(:method_call)            { parse('foo.bar(baz)')  }
  let(:attribute_read)         { parse('foo.bar')       }
  let(:attribute_assignment)   { parse('foo.bar = baz') }
  let(:binary_method_operator) { parse('foo == bar')    }

  exception = Class.new do
    include Mutant::Adamantium, Unparser::Anima.new(
      :name,
      :attribute_assignment,
      :binary_method_operator
    )

    define_singleton_method(:all) do
      [
        [:method_call,            false, false],
        [:attribute_read,         false, false],
        [:attribute_assignment,   true,  false],
        [:binary_method_operator, false, true]
      ].map do |values|
        new(anima.attribute_names.zip(values).to_h)
      end
    end
  end

  # Rspec should have a build in for this kind of "n-dimensional assertion with context"
  (exception.anima.attribute_names - %i[name]).each do |name|
    describe "##{name}?" do
      subject { object.public_send(:"#{name}?") }

      exception.all.each do |expectation|
        context "on #{expectation.name}" do
          let(:node) { public_send(expectation.name) }

          it { should be(expectation.public_send(name)) }
        end
      end
    end
  end
end
