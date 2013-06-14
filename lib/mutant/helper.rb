module Mutant
  # Module for support methods
  #
  # They would normally be defined on the root namespace.
  # But it is easier to create the Zombie when there are no
  # References to the root namespace name within the library.
  #
  module Helper

    # Return deep clone of object
    #
    # @param [Object] object
    #
    # @return [Object] object
    #
    # @api private
    #
    def self.deep_clone(object)
      Marshal.load(Marshal.dump(object))
    end

  end # Helper
end # Mutant
