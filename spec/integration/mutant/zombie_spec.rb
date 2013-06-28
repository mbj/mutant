require 'spec_helper'

describe Mutant, 'as a zombie' do
  specify 'it allows to create zombie from mutant' do
    Mutant::Zombifier.run('mutant')
    Zombie.constants.should include(:Mutant)
  end
end
