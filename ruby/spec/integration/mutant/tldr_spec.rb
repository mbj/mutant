# frozen_string_literal: true

RSpec.describe 'tldr integration', mutant: false do
  let(:base_cmd) do
    %w[
      bundle exec mutant run
      --include test
      --include ../lib
      --require test_app
      --integration tldr
      --usage opensource
    ]
  end

  let(:gemfile) { 'Gemfile' }

  it_behaves_like 'framework integration', :tldr
end
