# encoding: utf-8

module Mutant
  class CLI
    class Classifier

      # Scope classifier
      class Scope < self

        REGEXP = /\A(?<scope>#{SCOPE_PATTERN})\z/.freeze

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
          Classifier.constant_lookup(match[__method__].to_s)
        end

      end # Scope
    end # Classifier
  end # CLI
end # Mutant
