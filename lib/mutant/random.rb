module Mutant
  # Module for generating random values
  module Random

    # Return random hex string
    #
    # @return [String]
    #
    # @api private
    #
    def self.hex_string
      SecureRandom.hex(10)
    end

    # Return random fixnum
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def self.fixnum
      ::Random.rand(1000)
    end

    # Return random float
    #
    # @return [Float]
    #
    # @api private
    #
    def self.float
      ::Random.rand
    end
  end
end
