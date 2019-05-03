# frozen_string_literal: true

source 'https://rubygems.org'

gemspec name: 'mutant'

eval_gemfile File.expand_path('Gemfile.shared', __dir__)

gem(
  'devtools',
  git: 'https://github.com/mbj/devtools.git',
  ref: '26ba0a1053e6cf7b79fc72d513a73457f9a38ead'
)

# Mutant itself uses an opensource license key.
# Scoped to https://github.com/mbj/mutant it'll
# not be useful elsewhere.
source 'https://Px2ENN7S91OmWaD5G7MIQJi1dmtmYrEh@gem.mutant.dev' do
  gem 'mutant-license'
end
