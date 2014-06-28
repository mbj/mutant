# encoding: UTF-8
require 'rspec/core'
require 'rspec/version'

require 'rspec/core/formatters/base_text_formatter'

RSPEC_2_VERSION_PREFIX = '2.'.freeze

require 'mutant/integration/rspec'
if RSpec::Core::Version::STRING.start_with?(RSPEC_2_VERSION_PREFIX)
  require 'mutant/integration/rspec2'
else
  require 'mutant/integration/rspec3'
end
