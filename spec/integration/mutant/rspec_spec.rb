# frozen_string_literal: true

RSpec.describe 'rspec integration', mutant: false do
  let(:base_cmd) do
    %w[bundle exec mutant run -I lib --require test_app --integration rspec]
  end

  %w[3.8].each do |version|
    context "RSpec #{version}" do
      let(:gemfile) { "Gemfile.rspec#{version}" }

      it_behaves_like 'framework integration'
    end
  end
end
