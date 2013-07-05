module Mutant
  class Subject
    class Method
      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL = '#'.freeze

        # Test if method is public
        #
        # @return [true]
        #   if method is public
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def public?
          scope.public_method_defined?(name)
        end
        memoize :public?

      private

        # Mutator for memoized instance methods
        class Memoized < self
          include NodeHelpers

        private

          # Return mutations
          #
          # @return [Enumerable<Mutation>]
          #
          # @api private
          #
          def mutations
            Mutator.each(node).map do |mutant|
              Mutation::Evil.new(self, memoizer_node(mutant))
            end
          end

          # Return neutral mutation
          #
          # @return [Mutation::Neutral]
          #
          # @api private
          #
          def noop_mutation
            Mutation::Neutral::Noop.new(self, memoizer_node(node))
          end

          # Return memoizer node for mutant
          #
          # @param [Parser::AST::Node] mutant
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def memoizer_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:args, s(:sym, name))))
          end

        end # Memoized
      end # Instance
    end # Method
  end # Subject
end # Mutant
