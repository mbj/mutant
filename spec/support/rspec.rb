# Patch rspec to allow nested execution
module Rspec
  # Run block in clean rspec environment
  #
  # @return [Object]
  #   returns the value of block
  #
  # @api private
  #
  def self.nest
    original_world, original_configuration = 
      ::RSpec.instance_variable_get(:@world),
      ::RSpec.instance_variable_get(:@configuration)

    ::RSpec.reset

    yield
  ensure
    ::RSpec.instance_variable_set(:@world, original_world)
    ::RSpec.instance_variable_set(:@configuration, original_configuration)
  end
end
