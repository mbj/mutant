# frozen_string_literal: true

module Mutant
  class Subject
    class Method
      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL     = '#'

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          warnings.call do
            scope.public_send(:undef_method, name)
          end
          self
        end

        # Mutator for memoizable memoized instance methods
        class Memoized < self
          include AST::Sexp

          FREEZER_OPTION_VALUES = {
            Adamantium::Freezer::Deep => :deep,
            Adamantium::Freezer::Flat => :flat,
            Adamantium::Freezer::Noop => :noop
          }.freeze

          private_constant(*constants(false))

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            memory.delete(name)
            super()
          end

        private

          def wrap_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:sym, name), *options))
          end

          # The optional AST node for adamantium memoization options
          #
          # @return [Array(Parser::AST::Node), nil]
          def options
            # rubocop:disable Style/GuardClause
            if FREEZER_OPTION_VALUES.key?(freezer)
              [
                s(:kwargs,
                  s(:pair,
                    s(:sym, :freezer),
                    s(:sym, FREEZER_OPTION_VALUES.fetch(freezer))))
              ]
            end
            # rubocop:enable Style/GuardClause
          end

          # The freezer used for memoization
          #
          # @return [Object]
          def freezer
            memory.fetch(name).instance_variable_get(:@freezer)
          end
          memoize :freezer, freezer: :noop

          # The memory used for memoization
          #
          # @return [ThreadSafe::Cache]
          def memory
            scope.__send__(:memoized_methods).instance_variable_get(:@memory)
          end

        end # Memoized
      end # Instance
    end # Method
  end # Subject
end # Mutant
