# frozen_string_literal: true

module Mutant
  class AST
    # AST Structure metadata
    # rubocop:disable Metrics/ModuleLength
    module Structure
      class Node
        include Adamantium, Anima.new(:type, :fixed, :variable)

        class Fixed
          include Adamantium, Anima.new(:index, :name)

          class Descendant < self
          end

          class Attribute < self
          end

          def attribute?
            instance_of?(Attribute)
          end

          def descendant?
            instance_of?(Descendant)
          end

          def value(node)
            node.children.at(index)
          end
        end

        class Variable
          include Adamantium, Anima.new(:name, :range)

          class Descendants < self
            def nodes(node)
              node.children[range]
            end
          end

          class Attributes < self
            def nodes(_node)
              EMPTY_ARRAY
            end
          end
        end

        def each_descendant_deep(node, &block)
          each_descendant(node) do |descendant|
            block.call(descendant)
            Structure.for(descendant.type).each_descendant_deep(descendant, &block)
          end
        end

        def each_node(node, &block)
          block.call(node)
          each_descendant_deep(node, &block)
        end

        def each_descendant(node, &block)
          descendants.each_value do |descendant|
            value = descendant.value(node)

            block.call(value) if value
          end

          variable_descendants(node).each do |value|
            block.call(value) if value
          end

          self
        end

        def descendants
          fixed.select(&:descendant?).to_h { |child| [child.name, child] }
        end

        def attributes
          fixed.select(&:attribute?).to_h { |child| [child.name, child] }
        end

        def descendant(name)
          maybe_descendant(name) or fail "Node #{type} does not have fixed descendant #{name}"
        end

        def attribute(name)
          maybe_attribute(name) or fail "Node #{type} does not have fixed attribute #{name}"
        end

        def maybe_attribute(name)
          attributes[name]
        end

        def maybe_descendant(name)
          descendants[name]
        end

        def self.fixed(values)
          values.each_with_index.map do |(klass, name), index|
            klass.new(index:, name:)
          end
        end

      private

        def variable_descendants(node)
          return EMPTY_ARRAY unless variable

          variable.nodes(node)
        end
      end

      ALL = [
        Node.new(
          type:     :__ENCODING__,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :__FILE__,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :__LINE__,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :alias,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :source],
              [Node::Fixed::Descendant, :target]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :and,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :left],
              [Node::Fixed::Descendant, :right]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :and_asgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :arg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :args,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :arguments, range: 0..)
        ),
        Node.new(
          type:     :array,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :array_pattern,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :back_ref,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :begin,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :block,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :receiver],
              [Node::Fixed::Descendant, :arguments],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :blockarg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :block_pass,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :break,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :values, range: 0..)
        ),
        Node.new(
          type:     :case,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: Node::Variable::Descendants.new(name: :members, range: 1..)
        ),
        Node.new(
          type:     :case_match,
          fixed:    [
            Node::Fixed::Descendant.new(index: 0,  name: :target),
            Node::Fixed::Descendant.new(index: -1, name: :else_branch)
          ],
          variable: Node::Variable::Descendants.new(name: :patterns, range: 1..-2)
        ),
        Node.new(
          type:     :casgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :base],
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :cbase,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :class,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :superclass],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :complex,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :const,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :base],
              [Node::Fixed::Attribute, :name]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :const_pattern,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :pattern]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :csend,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :receiver],
              [Node::Fixed::Attribute, :selector]
            ]
          ),
          variable: Node::Variable::Descendants.new(name: :arguments, range: 2..)
        ),
        Node.new(
          type:     :cvar,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :cvasgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :defined?,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :dstr,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :dsym,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :def,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :arguments],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :defs,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :singleton],
              [Node::Fixed::Attribute,  :name],
              [Node::Fixed::Descendant, :arguments],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :empty_else,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :ensure,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :ensure_body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :eflipflop,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :start],
              [Node::Fixed::Descendant, :end]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :erange,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :begin],
              [Node::Fixed::Descendant, :end]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :false,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :float,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :forwarded_args,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :forwarded_kwrestarg,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :forwarded_restarg,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :for,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :source],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :gvar,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :gvasgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :hash,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :index,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :receiver]]),
          variable: Node::Variable::Descendants.new(name: :members, range: 1..)
        ),
        Node.new(
          type:     :indexasgn,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :receiver]]),
          variable: Node::Variable::Descendants.new(name: :members, range: 1..)
        ),
        Node.new(
          type:     :if,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :condition],
              [Node::Fixed::Descendant, :true_branch],
              [Node::Fixed::Descendant, :false_branch]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :iflipflop,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :start],
              [Node::Fixed::Descendant, :end]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :in_pattern,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :unless_guard],
              [Node::Fixed::Descendant, :branch],
              [Node::Fixed::Descendant, :else_branch]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :int,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :irange,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :begin],
              [Node::Fixed::Descendant, :end]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :ivar,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :ivasgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :kwarg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :kwargs,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :kwbegin,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :kwoptarg,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :kwrestarg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :kwsplat,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :lambda,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :lvar,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :lvasgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :match_current_line,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :pattern]]),
          variable: nil
        ),
        Node.new(
          type:     :match_pattern,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :pattern]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :match_rest,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :match_var,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :match_with_lvasgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :pattern],
              [Node::Fixed::Descendant, :target]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :masgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :targets],
              [Node::Fixed::Descendant, :values]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :mlhs,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :module,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :name],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: Node::Variable::Descendants.new(name: :members, range: 2..)
        ),
        Node.new(
          type:     :next,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :values, range: 0..)
        ),
        Node.new(
          type:     :nth_ref,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :numblock,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :receiver],
              [Node::Fixed::Attribute, :parameters],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :op_asgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Attribute, :operator],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :optarg,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Attribute, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :or,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :left],
              [Node::Fixed::Descendant, :right]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :or_asgn,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :target],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :rational,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :redo,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :regexp,
          fixed:    [
            Node::Fixed::Descendant.new(index: -1, name: :options)
          ],
          variable: Node::Variable::Descendants.new(name: :members, range: 0..-2)
        ),
        Node.new(
          type:     :regopt,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Attributes.new(name: :options, range: 0..)
        ),
        Node.new(
          type:     :rescue,
          fixed:    [
            Node::Fixed::Descendant.new(index: 0, name: :body),
            Node::Fixed::Descendant.new(index: 1, name: :resbody),
            Node::Fixed::Descendant.new(index: -1, name: :else_body)
          ],
          variable: Node::Variable::Descendants.new(name: :resbodies, range: 2..-2)
        ),
        Node.new(
          type:     :resbody,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :captures],
              [Node::Fixed::Descendant, :assignment],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :restarg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :retry,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :return,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :values, range: 0..)
        ),
        Node.new(
          type:     :self,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :send,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :receiver],
              [Node::Fixed::Attribute, :selector]
            ]
          ),
          variable: Node::Variable::Descendants.new(name: :arguments, range: 2..)
        ),
        Node.new(
          type:     :shadowarg,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :name]]),
          variable: nil
        ),
        Node.new(
          type:     :nil,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :preexe,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :body]]),
          variable: nil
        ),
        Node.new(
          type:     :pair,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :name],
              [Node::Fixed::Descendant, :value]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :postexe,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :body]]),
          variable: nil
        ),
        Node.new(
          type:     :procarg0,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :arguments, range: 0..)
        ),
        Node.new(
          type:     :sclass,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :singleton],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :splat,
          fixed:    Node.fixed([[Node::Fixed::Descendant, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :str,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :super,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :arguments, range: 0..)
        ),
        Node.new(
          type:     :sym,
          fixed:    Node.fixed([[Node::Fixed::Attribute, :value]]),
          variable: nil
        ),
        Node.new(
          type:     :true,
          fixed:    EMPTY_ARRAY,
          variable: nil
        ),
        Node.new(
          type:     :undef,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :until,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :condition],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :until_post,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :condition],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :when,
          fixed:    [Node::Fixed::Descendant.new(index: -1, name: :body)],
          variable: Node::Variable::Descendants.new(name: :conditions, range: 0..-2)
        ),
        Node.new(
          type:     :while_post,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :condition],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :while,
          fixed:    Node.fixed(
            [
              [Node::Fixed::Descendant, :condition],
              [Node::Fixed::Descendant, :body]
            ]
          ),
          variable: nil
        ),
        Node.new(
          type:     :xstr,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :members, range: 0..)
        ),
        Node.new(
          type:     :yield,
          fixed:    EMPTY_ARRAY,
          variable: Node::Variable::Descendants.new(name: :values, range: 0..)
        ),
        Node.new(
          type:     :zsuper,
          fixed:    EMPTY_ARRAY,
          variable: nil
        )
      ].to_h { |node| [node.type, node] }.freeze

      # Lookup AST structure for a specific type
      #
      # @param [Symbol] type
      #
      # @return [Structure]
      def self.for(type)
        ALL.fetch(type)
      end
    end # Structure
    # rubocop:enable Metrics/ModuleLength
  end # AST
end # Mutant
