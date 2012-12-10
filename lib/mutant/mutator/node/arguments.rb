module Mutant
  class Mutator
    class Node
      # Mutator for pattern arguments
      class PatternVariable < self

        handle(Rubinius::AST::PatternVariable)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:name)
        end
      end

      # Mutantor for default arguments
      class DefaultArguments < self
        handle(Rubinius::AST::DefaultArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:arguments) do |argument|
            argument.names = argument.arguments.map(&:name)
          end
        end
      end

      # Mutator for pattern arguments
      class PatternArguments < self

        handle(Rubinius::AST::PatternArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          Mutator.each(node.arguments.body) do |mutation|
            dup = dup_node
            dup.arguments.body = mutation
            emit(dup)
          end
        end

        # Test if mutation should be skipped
        #
        # @return [true]
        #   if mutation should be skipped
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def allow?(object)
          object.arguments.body.size >= 2
        end
      end

      # Mutator for formal arguments
      class FormatlArguments19 < self

      private

        handle(Rubinius::AST::FormalArguments19)

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          expand_pattern_args
          emit_default_mutations
          emit_required_defaults_mutation
          emit_attribute_mutations(:required) do |mutation|
            mutation.names = mutation.optional + mutation.required
          end
        end

        # Emit default mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_default_mutations
          return unless node.defaults
          emit_attribute_mutations(:defaults) do |mutation|
            mutation.optional = mutation.defaults.names
            mutation.names = mutation.required + mutation.optional
            if mutation.defaults.names.empty?
              mutation.defaults = nil
            end
          end 
        end

        # Emit required defaults mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_required_defaults_mutation
          return unless node.defaults
          arguments = node.defaults.arguments
          arguments.each_index do |index|
            names = arguments.take(index+1).map(&:name)
            dup = dup_node
            defaults = dup.defaults
            defaults.arguments = defaults.arguments.drop(names.size)
            names.each { |name| dup.optional.delete(name) }
            dup.required.concat(names)
            if dup.optional.empty?
              dup.defaults = nil
            end
            emit(dup)
          end
        end

        # Emit pattern args expansions
        # 
        # @return [undefined]
        #
        # @api private
        #
        def expand_pattern_args
          node.required.each_with_index do |argument, index|
            next unless argument.kind_of?(Rubinius::AST::PatternArguments)
            dup = dup_node
            required = dup.required
            required.delete_at(index)
            argument.arguments.body.reverse.each do |node|
              required.insert(index, node.name)
            end
            dup.names |= required
            emit(dup)
          end
        end
      end

      # Mutator for arguments
      class Arguments < self

        handle(Rubinius::AST::ActualArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:array)
        end

      end
    end
  end
end
