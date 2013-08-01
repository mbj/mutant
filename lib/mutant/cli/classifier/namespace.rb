# encoding: utf-8

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
          self.class::MATCHER.new(cache, namespace)
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
          REGEXP  = /\A(#{SCOPE_PATTERN})\*\z/.freeze
          MATCHER = Matcher::Namespace

          register
        end # Recursive

        # Recursive namespace classifier
        class Flat < self
          REGEXP  = /\A(#{SCOPE_PATTERN})\z/.freeze
          MATCHER = Matcher::Scope

          register
        end # Flat

      end # Namespace
    end # Classifier
  end # CLI
end # Mutant
