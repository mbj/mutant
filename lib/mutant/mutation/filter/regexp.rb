module Mutant
  class Mutation
    class Filter
      # Mutaiton filter filtering in regexp match on mutation identification
      class Regexp < self

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
          !!(@regexp =~ mutation.identification)
        end

      private

        # Initialize regexp filter
        #
        # @param [Regexp] regexp
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(regexp)
          @regexp = regexp
        end
      end
    end
  end
end
