# encoding: utf-8

module Mutant
  class CLI
    class Classifier

      # Namespace classifier
      class Namespace < self

        # Return matcher
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher
          self.class::MATCHER.new(cache, namespace)
        end

      private

        # Return namespace
        #
        # @return [Class, Module]
        #
        # @api private
        #
        def namespace
          Classifier.constant_lookup(match[__method__].to_s)
        end

        # Recursive namespace classifier
        class Recursive < self
          REGEXP  = /\A(?<namespace>#{SCOPE_PATTERN})\*\z/.freeze
          MATCHER = Matcher::Namespace
          register(REGEXP)
        end # Recursive

        # Recursive namespace classifier
        class Flat < self
          REGEXP  = /\A(?<namespace>#{SCOPE_PATTERN})\z/.freeze
          MATCHER = Matcher::Scope
          register(REGEXP)
        end # Flat

      end # Namespace
    end # Classifier
  end # CLI
end # Mutant
