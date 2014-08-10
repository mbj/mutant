RSpec.describe do

  specify 'mutant should not crash for any node parser can generate' do
    Mutant::AST::Types::ALL.each do |type|
      Mutant::Mutator::Registry.lookup(s(type))
    end
  end
end
