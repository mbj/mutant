require 'spec_helper'

describe Mutant, 'as a zombie' do
  specify 'allows to create zombie from mutant' do
    Zombie.setup
    Zombie::Runner
  end
end
