module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle variable assignment nodes
        class VariableAssignment < Node

          children :name, :value

          map = {
            gvasgn: '$',
            cvasgn: '@@',
            ivasgn: '@',
            lvasgn: EMPTY_STRING
          }

          MAP = IceNine.deep_freeze(
            Hash[map.map { |type, prefix| [type, [prefix, /^#{::Regexp.escape(prefix)}/]] }]
          )

          handle(*MAP.keys)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            return if lvar_used?

            emit_singletons unless parent_type.equal?(:mlhs)
            mutate_name
            emit_value_mutations if value # op asgn!
          end

          # Emit name mutations
          #
          # @return [undefined]
          def mutate_name
            prefix, regexp = MAP.fetch(node.type)
            stripped = name.to_s.sub(regexp, EMPTY_STRING)
            Util::Symbol.call(stripped).each do |name|
              emit_name(:"#{prefix}#{name}")
            end
          end

          # Test if a local variable is used within siblings
          #
          # @return [Boolean]
          def lvar_used?
            n_lvasgn?(node) && lvar_read?(name)
          end

          # Test if a local variable of a given name is read within siblings
          #
          # @param name [Symbol] name of lvar
          #
          # @return [Boolean]
          def lvar_read?(name)
            lvar_reads_in_scope.include?(s(:lvar, name))
          end

          # Local variables defined within sibling nodes defined after the current node
          #
          # @return [Array<Parser::AST::Node]
          def lvar_reads_in_scope
            recurse_siblings.select(&method(:n_lvar?))
          end
          memoize :lvar_reads_in_scope

          # Recurse through siblings defined after the current node
          #
          # @yield [Parser::AST::Node] node matching block provided
          #
          # @return [undefined]
          def recurse_siblings(&block)
            return to_enum(__method__) unless block_given?

            following_siblings.each { |sibling| recurse_node(sibling, &block) }
          end

          # Descend recursively into node
          #
          # @param node [Object]
          #
          # @yield [node] node matching block provided
          #
          # @return [undefinefd]
          def recurse_node(node, &block)
            return unless node.instance_of?(::Parser::AST::Node)

            yield(node)

            node.children.each { |child| recurse_node(child, &block) }
          end

          # Children of the parent defined after the current node
          #
          # @return [Array<Parser::AST::Node>]
          def following_siblings
            return [] unless parent

            parent.children.slice_when { |node| node.equal?(self) }.to_a.last
          end
          memoize :following_siblings

        end # VariableAssignment
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
