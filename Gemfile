# encoding: utf-8

source 'https://rubygems.org'

gemspec

gem 'mutant', path: '.'

group :development, :test do
  gem 'triage', git: 'https://github.com/rom-rb/devtools.git', :branch => 'triage-rename'
end

eval_gemfile File.join(File.dirname(__FILE__), 'Gemfile.triage')
