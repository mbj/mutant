# encoding: utf-8

source 'https://rubygems.org'

gemspec

gem 'mutant', path: '.'

gem 'rspec-core', path: '../rspec-core'

group :development, :test do
  gem 'devtools', git: 'https://github.com/rom-rb/devtools.git'
end

eval_gemfile File.join(File.dirname(__FILE__), 'Gemfile.devtools')
