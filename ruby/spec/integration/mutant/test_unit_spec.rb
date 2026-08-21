# frozen_string_literal: true

RSpec.describe 'test-unit integration', mutant: false do
  let(:base_cmd) do
    %w[
      bundle exec mutant run
      --include test_unit
      --include lib
      --require test_app
      --integration test-unit
      --usage opensource
    ]
  end

  let(:gemfile) { 'test_unit/Gemfile' }

  it_behaves_like 'framework integration'
end
