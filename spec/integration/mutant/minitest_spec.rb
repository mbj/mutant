# frozen_string_literal: true

RSpec.describe 'minitest integration', mutant: false do
  let(:base_cmd) do
    %w[bundle exec mutant run -I test -I lib --require test_app --use minitest]
  end

  let(:gemfile) { 'Gemfile.minitest' }

  it_behaves_like 'framework integration'
end
