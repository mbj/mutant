# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name        = 'mutant'
  gem.version     = '0.3.0.beta22'
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Mutation testing for ruby'
  gem.summary     = 'Mutation testing tool for ruby under MRI and Rubinius'
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- spec/{unit,integration}`.split("\n")
  gem.extra_rdoc_files = %w[TODO LICENSE]
  gem.executables      = %w[mutant]

  gem.add_runtime_dependency('parser',              '~> 2.0.0.pre5')
  gem.add_runtime_dependency('unparser',            '~> 0.0.14')
  gem.add_runtime_dependency('ice_nine',            '~> 0.8.0')
  gem.add_runtime_dependency('descendants_tracker', '~> 0.0.1')
  gem.add_runtime_dependency('adamantium',          '~> 0.0.10')
  gem.add_runtime_dependency('equalizer',           '~> 0.0.5')
  gem.add_runtime_dependency('inflecto',            '~> 0.0.2')
  gem.add_runtime_dependency('anima',               '~> 0.0.6')
  gem.add_runtime_dependency('concord',             '~> 0.1.3')
  gem.add_runtime_dependency('rspec',               '~> 2.14.1')

  gem.add_development_dependency('bundler', '~> 1.3', '>= 1.3.5')
end
