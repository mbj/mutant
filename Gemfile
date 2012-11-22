source 'https://rubygems.org'

gemspec

gem 'descendants_tracker', :git => 'https://github.com/dkubb/descendants_tracker.git'
gem 'abstract_class',      :git => 'https://github.com/dkubb/abstract_class.git'
gem 'to_source',           :git => 'https://github.com/mbj/to_source.git'
gem 'melbourne',           :git => 'https://github.com/mbj/melbourne.git'
gem 'inflector',           :git => 'https://github.com/mbj/inflector.git'

group :development do
  gem 'rake',    '~> 0.9.2'
  gem 'yard',    '~> 0.8.1'
  gem 'rspec',   '~> 2'
end

group :guard do
  gem 'guard',         '~> 1.3.2'
  gem 'guard-bundler', '~> 1.0.0'
  gem 'guard-rspec',   '~> 1.2.1'
  # Remove this once https://github.com/nex3/rb-inotify/pull/20 is solved.
  # This patch makes rb-inotify a nice player with listen so it does not poll.
  gem 'rb-inotify', :git => 'https://github.com/mbj/rb-inotify'
end

group :metrics do
  gem 'flay',            '~> 1.4.2'
  gem 'flog',            '~> 2.5.1'
  gem 'reek',            '~> 1.2.8', :git => 'https://github.com/dkubb/reek.git'
  gem 'roodi',           '~> 2.1.0'
  gem 'yardstick',       '~> 0.5.0'
  gem 'yard-spellcheck', '~> 0.1.5'
  gem 'pelusa',          '~> 0.2.1'
end
