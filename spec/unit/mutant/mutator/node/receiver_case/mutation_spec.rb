require 'spec_helper'

describe Mutant::Mutator::Node::ReceiverCase do
  let(:source) { 'case self.condition; when true; true; when false; false; else raise; end' }

  let(:mutations) do
    mutations = []

    # Delete each when once
    mutations << 'case self.condition; when true; true; else raise; end'
    mutations << 'case self.condition; when false; false; else raise; end'

    # Mutate receiver
    mutations << 'case condition; when true; true; when false; false; else raise; end'

    # Remove else branch
    mutations << 'case self.condition; when true; true; when false; false; end'

    # Mutate when branch bodies
    mutations << 'case self.condition; when true; nil;   when false; false; else raise; end'
    mutations << 'case self.condition; when true; false; when false; false; else raise; end'
    mutations << 'case self.condition; when true; true;  when false; nil;   else raise; end'
    mutations << 'case self.condition; when true; true;  when false; true;  else raise; end'
  end

  it_should_behave_like 'a mutator'
end
