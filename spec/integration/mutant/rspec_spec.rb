RSpec.describe 'rspec integration', mutant: false do

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use rspec' }

  context 'RSpec 3.0' do
    let(:gemfile) { 'Gemfile.rspec3.0' }

    it_behaves_like 'framework integration'
  end

  context 'RSpec 3.1' do
    let(:gemfile) { 'Gemfile.rspec3.1' }

    it_behaves_like 'framework integration'
  end

  context 'RSpec 3.2' do
    let(:gemfile) { 'Gemfile.rspec3.2' }

    it_behaves_like 'framework integration'
  end
end
