module Mutant
  class CLI
    class Classifier

      # Scope classifier
      class Scope < self

        REGEXP = %r(\A(#{SCOPE_PATTERN})\z).freeze

      private

        # Return matcher
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher
          Matcher::Scope.new(scope)
        end

        # Return namespace
        #
        # @return [Class, Module]
        #
        # @api private
        #
        def scope
          Classifier.constant_lookup(match[1].to_s)
        end

      end
    end
  end
end
