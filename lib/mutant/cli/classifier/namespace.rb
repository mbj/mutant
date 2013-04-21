module Mutant
  class CLI
    class Classifier

      # Namespace classifier
      class Namespace < self

      private

        # Return matcher
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher
          self.class::MATCHER.new(namespace)
        end

        # Return namespace
        #
        # @return [Class, Module]
        #
        # @api private
        #
        def namespace
          Classifier.constant_lookup(match[1].to_s)
        end

        # Recursive namespace classifier
        class Recursive < self
          REGEXP = %r(\A(#{SCOPE_PATTERN})\*\z).freeze
          MATCHER = Matcher::Namespace
          register
        end

        # Recursive namespace classifier
        class Flat < self
          REGEXP = %r(\A(#{SCOPE_PATTERN})\z).freeze
          MATCHER = Matcher::Scope
          register
        end
      end
    end
  end
end
