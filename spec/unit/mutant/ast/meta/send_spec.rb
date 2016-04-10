RSpec.describe Mutant::AST::Meta::Send do
  let(:object) { described_class.new(node) }

  def parse(source)
    Parser::CurrentRuby.parse(source)
  end

  let(:method_call)            { parse('foo.bar(baz)')  }
  let(:attribute_read)         { parse('foo.bar')       }
  let(:index_assignment)       { parse('foo[0] = bar')  }
  let(:attribute_assignment)   { parse('foo.bar = baz') }
  let(:binary_method_operator) { parse('foo == bar')    }

  class Expectation
    include Adamantium, Anima.new(:name, :assignment, :attribute_assignment, :index_assignment, :binary_method_operator)

    ALL = [
      [:method_call,            false, false, false, false],
      [:attribute_read,         false, false, false, false],
      [:index_assignment,       true,  false, true,  false],
      [:attribute_assignment,   true,  true,  false, false],
      [:binary_method_operator, false, false, false, true]
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
