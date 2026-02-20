# frozen_string_literal: true

RSpec.describe 'rspec integration', mutant: false do
  let(:base_cmd) do
    %w[
      bundle exec mutant run
      --include lib
      --integration rspec
      --require test_app
      --usage opensource
    ]
  end

  %w[3.8 3.9 3.10 3.11 3.12 3.13 4.0].each do |version|
    context "RSpec #{version}" do
      let(:gemfile) { "Gemfile.rspec#{version}" }

      it_behaves_like 'framework integration'

      it 'handles invalid rspec' do
        Dir.chdir('test_app') do
          result = Kernel.system(
            { 'BUNDLE_GEMFILE' => gemfile },
            *%w[bundle exec mutant environment test run --integration rspec -- --backtrace
                spec/unit/test_app/invalid.rb]
          )

          expect(result).to be(false)
        end
      end
    end
  end
end
