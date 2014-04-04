# encoding: utf-8

require 'spec_helper'

describe 'as a zombie' do
  specify 'it allows to create zombie from mutant' do
    expect { Mutant.zombify }.to change { !!defined?(Zombie) }.from(false).to(true)
    expect(Zombie.constants).to include(:Mutant)
  end
end
