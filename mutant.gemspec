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

  exclusion = Dir.glob('lib/mutant/{integration/{minitest,rspec}.rb,minitest}')

  gem.files            = Dir.glob('lib/**/*') - exclusion
  gem.extra_rdoc_files = %w[LICENSE]
  gem.executables      = %w[mutant]

  gem.required_ruby_version = '>= 2.5'

  gem.add_runtime_dependency('abstract_type', '~> 0.0.7')
  gem.add_runtime_dependency('adamantium',    '~> 0.2.0')
  gem.add_runtime_dependency('anima',         '~> 0.3.1')
  gem.add_runtime_dependency('ast',           '~> 2.2')
  gem.add_runtime_dependency('concord',       '~> 0.1.5')
  gem.add_runtime_dependency('diff-lcs',      '~> 1.3')
  gem.add_runtime_dependency('equalizer',     '~> 0.0.9')
  gem.add_runtime_dependency('ice_nine',      '~> 0.11.1')
  gem.add_runtime_dependency('memoizable',    '~> 0.4.2')
  gem.add_runtime_dependency('mprelude',      '~> 0.1.0')
  gem.add_runtime_dependency('parser',        '~> 2.7.1')
  gem.add_runtime_dependency('procto',        '~> 0.0.2')
  gem.add_runtime_dependency('unparser',      '~> 0.5.3')
  gem.add_runtime_dependency('variable',      '~> 0.0.1')

  gem.add_development_dependency('parallel',   '~> 1.3')
  gem.add_development_dependency('rspec',      '~> 3.9')
  gem.add_development_dependency('rspec-core', '~> 3.9')
  gem.add_development_dependency('rspec-its',  '~> 1.3.0')
  gem.add_development_dependency('rubocop',    '~> 0.93')
end
