RSpec.describe do

  specify 'mutant should not crash for any node parser can generate' do
    Mutant::AST::Types::ALL.each do |type|
      Mutant::Mutator::REGISTRY.lookup(s(type))
    end
  end
end
