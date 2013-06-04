module Mutant
  class Mutator
    class Node

      # Mutator for required arguments
      class Argument < self
        handle(:arg)

        UNDERSCORE = '_'.freeze
        NAME_INDEX = 0

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          return if skip?
          emit_name_mutation
        end

        # Emit name mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_name_mutation
          Mutator::Util::Symbol.each(name) do |name|
            emit_child_update(NAME_INDEX, name)
          end
        end

        # Return name
        #
        # @return [Symbol]
        #
        # @api private
        #
        def name
          children[NAME_INDEX]
        end
        protected :name

        # Test if argument mutation is skipped
        #
        # @return [true]
        #   if argument should not get mutated
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def skip?
          name.to_s.start_with?(UNDERSCORE)
        end

        # Mutator for optional arguments
        class Optional < self

          handle(:optarg)

          DEFAULT_INDEX = 1

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_name_mutation
            emit_required_mutation
            emit_default_mutations
          end

          # Emit required mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_required_mutation
            emit(s(:arg, name))
          end

          # Emit default mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_default_mutations
            mutate_child(DEFAULT_INDEX)
          end

        end # Optional

      end # Argument
    end # Node
  end # Mutator
end # Mutant
