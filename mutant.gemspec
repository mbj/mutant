# frozen_string_literal: true

require File.expand_path('lib/mutant/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'mutant'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Mutation Testing for Ruby.'
  gem.summary     = ''
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'Nonstandard'

  gem.require_paths = %w[lib]

  exclusion = Dir.glob('lib/mutant/{integration/{minitest,rspec}.rb,minitest/**.rb}')

  gem.files            = Dir.glob('lib/**/*') - exclusion
  gem.extra_rdoc_files = %w[LICENSE]
  gem.executables      = %w[mutant]

  gem.metadata['rubygems_mfa_required'] = 'true'
  gem.metadata['source_code_uri'] = 'https://github.com/mbj/mutant'

  gem.required_ruby_version = '>= 3.2'

  gem.add_dependency('diff-lcs',       '~> 1.3')
  gem.add_dependency('parser',         '~> 3.3.0')
  gem.add_dependency('regexp_parser',  '~> 2.9.0')
  gem.add_dependency('sorbet-runtime', '~> 0.5.0')
  gem.add_dependency('unparser',       '~> 0.7.0')

  gem.add_development_dependency('rspec',      '~> 3.10')
  gem.add_development_dependency('rspec-core', '~> 3.10')
  gem.add_development_dependency('rspec-its',  '~> 1.3.0')
  gem.add_development_dependency('rubocop',    '~> 1.7')
end
