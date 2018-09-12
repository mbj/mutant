# frozen_string_literal: true

RSpec.describe 'AST type coverage', mutant: false do
  specify 'mutant should not crash for any node parser can generate' do
    Mutant::AST::Types::ALL.each do |type|
      Mutant::Mutator::REGISTRY.lookup(type)
    end
  end
end
