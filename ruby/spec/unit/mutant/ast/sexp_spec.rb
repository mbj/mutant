# frozen_string_literal: true

RSpec.describe Mutant::AST::Sexp do
  let(:object) do
    Class.new do
      include Mutant::AST::Sexp

      public :n_not
      public :s
    end.new
  end

  describe '#n_not' do
    subject { object.n_not(node) }

    let(:node) { s(:true) }

    it 'returns negated ast' do
      expect(subject).to eql(s(:send, s(:true), :!))
    end
  end

  describe '#s' do
    subject { object.s(*arguments) }

    context 'with single argument' do
      let(:arguments) { %i[foo] }

      it { should eql(Parser::AST::Node.new(:foo)) }
    end

    context 'with single multiple arguments' do
      let(:arguments) { %i[foo bar baz] }

      it { should eql(Parser::AST::Node.new(:foo, %i[bar baz])) }
    end
  end
end
