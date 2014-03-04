# encoding: utf-8

require 'spec_helper'

describe Mutant, 'as a zombie' do
  pending 'it allows to create zombie from mutant' do
    Mutant::Zombifier.run('mutant')
    expect(Zombie.constants).to include(:Mutant)
  end
end
