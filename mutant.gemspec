require File.expand_path('../lib/mutant/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'mutant'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Mutation testing for ruby'
  gem.summary     = 'Mutation testing tool for ruby under MRI and Rubinius'
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'MIT'

  gem.require_paths = %w[lib]

  mutant_integration_files = `git ls-files -- lib/mutant/integration/*.rb`.split("\n")

  gem.files            = `git ls-files`.split("\n") - mutant_integration_files
  gem.test_files       = `git ls-files -- spec/{unit,integration}`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE]
  gem.executables      = %w[mutant]

  gem.required_ruby_version = '>= 2.1'

  gem.add_runtime_dependency('parser',        '>= 2.3.1.4', '< 2.5')
  gem.add_runtime_dependency('ast',           '~> 2.2')
  gem.add_runtime_dependency('diff-lcs',      '~> 1.3')
  gem.add_runtime_dependency('parallel',      '~> 1.3')
  gem.add_runtime_dependency('morpher',       '~> 0.2.6')
  gem.add_runtime_dependency('procto',        '~> 0.0.2')
  gem.add_runtime_dependency('abstract_type', '~> 0.0.7')
  gem.add_runtime_dependency('unparser',      '~> 0.2.5')
  gem.add_runtime_dependency('ice_nine',      '~> 0.11.1')
  gem.add_runtime_dependency('adamantium',    '~> 0.2.0')
  gem.add_runtime_dependency('memoizable',    '~> 0.4.2')
  gem.add_runtime_dependency('equalizer',     '~> 0.0.9')
  gem.add_runtime_dependency('anima',         '~> 0.3.0')
  gem.add_runtime_dependency('concord',       '~> 0.1.5')
  gem.add_runtime_dependency('regexp_parser', '~> 0.4.3')

  gem.add_development_dependency('devtools', '~> 0.1.12')
  gem.add_development_dependency('bundler',  '~> 1.10')
  gem.add_development_dependency('ffi',      '~> 1.9.6')
end
