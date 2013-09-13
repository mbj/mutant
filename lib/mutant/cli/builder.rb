# encoding: utf-8

module Mutant
  class CLI
    # Abstract base class for strategy builders
    class Builder
      include AbstractType

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

      # Rspec strategy builder
      class Rspec < self

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(*)
          @level = 0
          @rspec = false
          super
        end

        # Return strategy
        #
        # @return [Strategy::Rspec]
        #
        # @api private
        #
        def output
          unless @rspec
            raise Error, 'No strategy given'
          end

          Strategy::Rspec.new(@level)
        end

      private

        # Set rspec level
        #
        # @return [self]
        #
        # @api private
        #
        def set_level(level)
          @level = level
          self
        end

        # Add cli options
        #
        # @param [OptionParser] parser
        #
        # @return [undefined]
        #
        # @api private
        #
        def add_options
          parser.on('--rspec', 'kills mutations with rspec') do
            @rspec = true
          end

          parser.on('--rspec-level LEVEL', 'set rspec expansion level') do |level|
            @level = level.to_i
          end
        end

      end # Rspec

      # Abstract predicate builder
      class Predicate < self

        class Subject < self

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

        end

      end # Predicate

    end # Builder
  end # CLI
end # Mutant
