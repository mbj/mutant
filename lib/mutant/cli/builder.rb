# encoding: utf-8

module Mutant
  class CLI
    # Abstract base class for strategy builders
    class Builder
      include AbstractType

      REGISTRY = {}

      # Register builder
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.register(instance_variable_name)
        REGISTRY[self] = instance_variable_name
      end

      # Return cache
      #
      # @return [Cache]
      #
      # @api private
      #
      attr_reader :cache
      private :cache

      # Return parser
      #
      # @return [OptionParser]
      #
      # @api private
      #
      attr_reader :parser
      private :parser

      # Initialize builder
      #
      # @param [OptionParser] parser
      #
      # @api privateo
      #
      def initialize(cache, parser)
        @cache, @parser = cache, parser
        add_options
      end

      # Add cli options
      #
      # @param [OptionParser]
      #
      # @return [self]
      #
      # @api private
      #
      abstract_method :add_options

      # Return build output
      #
      # @return [Object]
      #
      # @api private
      #
      abstract_method :output

      # Abstract predicate builder
      class Predicate < self

        # Bubject predicate builder
        class Subject < self

          register :@subject_predicate

          # Initialize object
          #
          # @api private
          #
          # @return [undefined]
          #
          def initialize(*)
            super
            @predicates = []
          end

          # Return predicate
          #
          # @api private
          #
          def output
            if @predicates.empty?
              Mutant::Predicate::CONTRADICTION
            else
              Mutant::Predicate::Whitelist.new(@predicates)
            end
          end

        private

          # Add cli options
          #
          # @return [undefined]
          #
          # @api private
          #
          def add_options
            parser.on('--ignore-subject MATCHER', 'ignores subjects that matches MATCHER') do |pattern|
              add_pattern(pattern)
            end
          end

          # Add matcher to predicates
          #
          # @param [String] pattern
          #
          # @api private
          #
          def add_pattern(pattern)
            matcher = Classifier.run(@cache, pattern)
            @predicates << Mutant::Predicate::Matcher.new(matcher)
          end

        end # Subject

      end # Predicate

    end # Builder
  end # CLI
end # Mutant
