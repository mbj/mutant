module Mutant
  class Mutation
    class Filter
      # Mutaiton filter filtering in regexp match on mutation identification
      class Regexp < self
        include Concord::Public.new(:regexp)

        # Test for match
        #
        # @param [Mutation] mutation
        #
        # @return [true]
        #   returns true if mutation identification is matched by regexp
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match?(mutation)
          !!(regexp =~ mutation.identification)
        end

      end # Regexp
    end # Filter
  end # Mutation
end # Mutant
