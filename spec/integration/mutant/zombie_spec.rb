RSpec.describe 'as a zombie' do
  specify 'it allows to create zombie from mutant' do
    expect { Mutant.zombify }.to change { defined?(Zombie) }.from(nil).to('constant')
    expect(Zombie.constants).to include(:Mutant)
  end
end
