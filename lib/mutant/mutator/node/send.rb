# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      # rubocop:disable Metrics/ClassLength
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
          flat_map:      %i[map],
          send:          %i[public_send __send__],
          __send__:      %i[public_send],
          method:        %i[public_method],
          gsub:          %i[sub],
          eql?:          %i[equal?],
          to_s:          %i[to_str],
          to_i:          %i[to_int],
          to_a:          %i[to_ary],
          to_h:          %i[to_hash],
          at:            %i[fetch key?],
          fetch:         %i[key?],
          values_at:     %i[fetch_values],
          :== =>         %i[eql? equal?],
          :>= =>         %i[> == eql? equal?],
          :<= =>         %i[< == eql? equal?],
          :> =>          %i[== eql? equal?],
          :< =>          %i[== eql? equal?]
        )

        RECEIVER_SELECTOR_REPLACEMENTS = IceNine.deep_freeze(
          Date: {
            parse: %i[jd civil strptime iso8601 rfc3339 xmlschema rfc2822 rfc822 httpdate jisx0301]
          }
        )

      private

        def dispatch
          emit_singletons

          if meta.binary_method_operator?
            run(Binary)
          elsif meta.attribute_assignment?
            run(AttributeAssignment)
          else
            normal_dispatch
          end
        end

        def meta
          AST::Meta::Send.new(node)
        end
        memoize :meta

        alias_method :arguments, :remaining_children
        private :arguments

        def normal_dispatch
          emit_naked_receiver
          emit_selector_replacement
          emit_selector_specific_mutations
          emit_argument_propagation
          emit_receiver_selector_mutations
          mutate_receiver
          mutate_arguments
        end

        def emit_selector_specific_mutations
          emit_array_mutation
          emit_static_send
          emit_const_get_mutation
          emit_integer_mutation
          emit_dig_mutation
          emit_double_negation_mutation
          emit_lambda_mutation
        end

        def emit_array_mutation
          return unless selector.equal?(:Array) && possible_kernel_method?

          emit(s(:array, *arguments))
        end

        def emit_static_send
          return unless %i[__send__ send public_send].include?(selector)

          dynamic_selector, *actual_arguments = *arguments

          return unless n_sym?(dynamic_selector)

          method_name = AST::Meta::Symbol.new(dynamic_selector).name

          emit(s(:send, receiver, method_name, *actual_arguments))
        end

        def possible_kernel_method?
          receiver.nil? || receiver.eql?(s(:const, nil, :Kernel))
        end

        def emit_receiver_selector_mutations
          return unless meta.receiver_possible_top_level_const?

          RECEIVER_SELECTOR_REPLACEMENTS
            .fetch(receiver.children.last, EMPTY_HASH)
            .fetch(selector, EMPTY_ARRAY)
            .each(&method(:emit_selector))
        end

        def emit_double_negation_mutation
          return unless selector.equal?(:!) && n_send?(receiver)

          negated = AST::Meta::Send.new(meta.receiver)
          emit(negated.receiver) if negated.selector.equal?(:!)
        end

        def emit_lambda_mutation
          emit(s(:send, nil, :lambda)) if meta.proc?
        end

        def emit_dig_mutation
          return if !selector.equal?(:dig) || arguments.none?

          head, *tail = arguments

          fetch_mutation = s(:send, receiver, :fetch, head)

          return emit(fetch_mutation) if tail.empty?

          emit(s(:send, fetch_mutation, :dig, *tail))
        end

        def emit_integer_mutation
          return unless selector.equal?(:to_i)

          emit(s(:send, nil, :Integer, receiver))
        end

        def emit_const_get_mutation
          return unless selector.equal?(:const_get) && n_sym?(arguments.first)

          emit(s(:const, receiver, AST::Meta::Symbol.new(arguments.first).name))
        end

        def emit_selector_replacement
          SELECTOR_REPLACEMENTS.fetch(selector, EMPTY_ARRAY).each(&method(:emit_selector))
        end

        def emit_naked_receiver
          emit(receiver) if receiver
        end

        def mutate_arguments
          emit_type(receiver, selector)
          remaining_children_with_index.each do |_node, index|
            mutate_argument_index(index)
            delete_child(index)
          end
        end

        def mutate_argument_index(index)
          mutate_child(index) { |node| !n_begin?(node) }
        end

        def emit_argument_propagation
          emit_propagation(Mutant::Util.one(arguments)) if arguments.one?
        end

        def mutate_receiver
          return unless receiver
          emit_implicit_self
          emit_receiver_mutations do |node|
            !n_nil?(node)
          end
        end

        def emit_implicit_self
          emit_receiver(nil) if n_self?(receiver) && !(
            KEYWORDS.include?(selector) ||
            meta.attribute_assignment?
          )
        end

      end # Send
    end # Node
  end # Mutator
end # Mutant
