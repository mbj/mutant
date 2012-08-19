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
    
    # Check for ruby-1.8 mode
    #
    # @return [true]
    #   returns true if running under 1.8 mode
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    def self.on_18?
      RUBY_VERSION == '1.8.7'
    end

    # Extract option from options hash
    #
    # @param [Hash] options
    # @param [Object] key
    #
    # @return [Object] value
    # 
    # @api private
    #
    def self.extract_option(options, key)
      options.fetch(key) do
        raise ArgumentError,"Missing #{key.inspect} in options"
      end
    end

  end
end
