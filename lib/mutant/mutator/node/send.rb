module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      # rubocop:disable ClassLength
      class Send < self
        include AST::Types

        handle(:send)

        children :receiver, :selector

        SELECTOR_REPLACEMENTS = IceNine.deep_freeze(
          reverse_map:   %i[map each],
          kind_of?:      %i[instance_of?],
          is_a?:         %i[instance_of?],
          reverse_each:  %i[each],
          reverse_merge: %i[merge],
          map:           %i[each],
          send:          %i[public_send __send__],
          __send__:      %i[public_send],
          method:        %i[public_method],
          gsub:          %i[sub],
          eql?:          %i[equal?],
          to_s:          %i[to_str],
          to_i:          %i[to_int],
          to_a:          %i[to_ary to_set],
          to_h:          %i[to_hash],
          at:            %i[fetch key?],
          fetch:         %i[key?],
          values_at:     %i[fetch_values],
          :[] =>         %i[at fetch key?],
          :== =>         %i[eql? equal?],
          :>= =>         %i[> == eql? equal?],
          :<= =>         %i[< == eql? equal?],
          :> =>          %i[== >= eql? equal?],
          :< =>          %i[== <= eql? equal?]
        )

        RECEIVER_SELECTOR_REPLACEMENTS = IceNine.deep_freeze(
          Date: {
            parse: %i[jd civil strptime iso8601 rfc3339 xmlschema rfc2822 rfc822 httpdate jisx0301]
          }
        )

      private

        # Perform dispatch
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          if meta.index_assignment?
            run(Index::Assign)
          else
            non_index_dispatch
          end
        end

        # Perform non index dispatch
        #
        # @return [undefined]
        def non_index_dispatch
          if meta.binary_method_operator?
            run(Binary)
          elsif meta.attribute_assignment?
            run(AttributeAssignment)
          else
            normal_dispatch
          end
        end

        # AST metadata for node
        #
        # @return [AST::Meta::Send]
        def meta
          AST::Meta::Send.new(node)
        end
        memoize :meta

        # Arguments being send
        #
        # @return [Enumerable<Parser::AST::Node>]
        alias_method :arguments, :remaining_children

        # Perform normal, non special case dispatch
        #
        # @return [undefined]
        def normal_dispatch
          emit_naked_receiver
          emit_selector_replacement
          emit_selector_specific_mutations
          emit_argument_propagation
          emit_receiver_selector_mutations
          mutate_receiver
          mutate_arguments
        end

        # Emit mutations which only correspond to one selector
        #
        # @return [undefined]
        def emit_selector_specific_mutations
          emit_const_get_mutation
          emit_integer_mutation
        end

        # Emit selector mutations specific to top level constants
        #
        # @return [undefined]
        def emit_receiver_selector_mutations
          return unless meta.receiver_possible_top_level_const?

          RECEIVER_SELECTOR_REPLACEMENTS
            .fetch(receiver.children.last, EMPTY_HASH)
            .fetch(selector, EMPTY_ARRAY)
            .each(&method(:emit_selector))
        end

        # Emit mutation from `to_i` to `Integer(...)`
        #
        # @return [undefined]
        def emit_integer_mutation
          return unless selector.equal?(:to_i)

          emit(s(:send, nil, :Integer, receiver))
        end

        # Emit mutation from `const_get` to const literal
        #
        # @return [undefined]
        def emit_const_get_mutation
          return unless selector.equal?(:const_get) && n_sym?(arguments.first)

          emit(s(:const, receiver, AST::Meta::Symbol.new(arguments.first).name))
        end

        # Emit selector replacement
        #
        # @return [undefined]
        def emit_selector_replacement
          SELECTOR_REPLACEMENTS.fetch(selector, EMPTY_ARRAY).each(&method(:emit_selector))
        end

        # Emit naked receiver mutation
        #
        # @return [undefined]
        def emit_naked_receiver
          emit(receiver) if receiver && !NOT_ASSIGNABLE.include?(receiver.type)
        end

        # Mutate arguments
        #
        # @return [undefined]
        def mutate_arguments
          emit_type(receiver, selector)
          remaining_children_with_index.each do |_node, index|
            mutate_child(index)
            delete_child(index)
          end
        end

        # Emit argument propagation
        #
        # @return [undefined]
        def emit_argument_propagation
          node = arguments.first
          emit(node) if arguments.one? && !NOT_STANDALONE.include?(node.type)
        end

        # Emit receiver mutations
        #
        # @return [undefined]
        def mutate_receiver
          return unless receiver
          emit_implicit_self
          emit_receiver_mutations do |node|
            !n_nil?(node)
          end
        end

        # Emit implicit self mutation
        #
        # @return [undefined]
        def emit_implicit_self
          emit_receiver(nil) if n_self?(receiver) && !(
            KEYWORDS.include?(selector)         ||
            METHOD_OPERATORS.include?(selector) ||
            meta.attribute_assignment?
          )
        end

      end # Send
    end # Node
  end # Mutator

end # Mutant
