module Mutant
  # Module to define simple inspect method
  module SimpleInspect

    # Return simple inspect string
    #
    # @return [String]
    #
    # @api private
    #
    def inspect
      "<#{self.class.name}>"
    end

  end # SimpleInspect
end # Mutant
