Rspec.describe 'minitest integration', mutant: false do

  let(:base_cmd) { 'bundle exec mutant -I test -I lib --require test_app --use minitest' }

  context 'Minitest 5.5.0' do
    let(:gemfile)  { 'Gemfile.minitest-stdlib' }

    it_behaves_like 'framework integration'
  end
end
