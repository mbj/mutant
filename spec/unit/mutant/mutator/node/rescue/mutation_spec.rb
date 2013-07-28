require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'rescue' do
  let(:source)    { 'begin; rescue Exception => e; end' }
  let(:mutations) { []                                  }

  # TODO: remove once unparser is fixed
  it 'does not raise an exception when unparsing source' do
    pending 'unparser bug' do
      expect { Unparser.unparse(Parser::CurrentRuby.parse(source)) }
        .to_not raise_error
    end
  end

  pending 'unparser bug' do
    it_should_behave_like 'a mutator'
  end
end
