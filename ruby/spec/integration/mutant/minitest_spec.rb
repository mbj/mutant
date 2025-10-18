# frozen_string_literal: true

RSpec.describe 'minitest integration', mutant: false do
  let(:base_cmd) do
    %w[
      bundle exec mutant run
      --include test
      --include lib
      --require test_app
      --integration minitest
      --usage opensource
    ]
  end

  let(:gemfile) { 'Gemfile.minitest' }

  it_behaves_like 'framework integration'
end
