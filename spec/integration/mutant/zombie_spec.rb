require 'spec_helper'

describe Mutant, 'as a zombie' do
  specify 'allows to create zombie from mutant' do
    Zombie.setup
    Zombie::Loader # constant created from zombie creation
  end
end
