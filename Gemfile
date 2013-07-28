# encoding: utf-8

source 'https://rubygems.org'

gemspec

gem 'mutant', path: '.'

group :development, :test do
  gem 'devtools', git: 'https://github.com/rom-rb/devtools.git'
end

eval_gemfile File.join(File.dirname(__FILE__), 'Gemfile.devtools')
