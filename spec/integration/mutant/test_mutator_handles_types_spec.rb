require 'spec_helper'

describe do

  specify 'mutant should not crash for any node parser can generate' do
    Mutant::NODE_TYPES.each do |type|
      Mutant::Mutator::Registry.lookup(Mutant::NodeHelpers.s(type))
    end
  end
end
