module Mutant
  class Mutator
    class Node
      class Assignment < self

      private

        class Variable < self

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_attribute_mutations(:name) do |mutation|
              mutation.name = "#{self.class::PREFIX}#{mutation.name}".to_sym
            end
            emit_attribute_mutations(:value)
          end

          class Local < self
            PREFIX = ''.freeze
            handle(Rubinius::AST::LocalVariableAssignment)
          end

          class Instance < self
            PREFIX = '@'.freeze
            handle(Rubinius::AST::InstanceVariableAssignment)
          end

          class Class < self
            PREFIX = '@@'.freeze
            handle(Rubinius::AST::ClassVariableAssignment)
          end

          class Global < self
            PREFIX = '$'.freeze
            handle(Rubinius::AST::GlobalVariableAssignment)
          end

        end

      end
    end
  end
end
