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

        # Test if node is new
        #
        # Note: to_source does not handle PatternVariableNodes as entry points
        #
        # @param [Rubinius::AST::Node] generated
        #
        # @return [true]
        #   if node is new
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def new?(generated)
          node.name != generated.name
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
            dup_args = dup.arguments.dup
            dup_args.body = mutation
            dup.arguments = dup_args
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
          emit_attribute_mutations(:required)
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
            required = node.required.dup
            required.delete_at(index)
            argument.arguments.body.reverse.each do |node|
              required.insert(index, node.name)
            end
            dup = dup_node
            dup.required = required
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
