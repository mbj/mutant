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

        SELECTOR_REPLACEMENTS = {
          :< =>          %i[== eql? equal?],
          :<= =>         %i[< == eql? equal?],
          :== =>         %i[eql? equal?],
          :=== =>        %i[is_a?],
          :=~ =>         %i[match?],
          :> =>          %i[== eql? equal?],
          :>= =>         %i[> == eql? equal?],
          __send__:      %i[public_send],
          all?:          %i[any?],
          any?:          %i[all?],
          at:            %i[fetch key?],
          fetch:         %i[key?],
          flat_map:      %i[map],
          gsub:          %i[sub],
          is_a?:         %i[instance_of?],
          kind_of?:      %i[instance_of?],
          map:           %i[each],
          match:         %i[match?],
          method:        %i[public_method],
          reverse_each:  %i[each],
          reverse_map:   %i[map each],
          reverse_merge: %i[merge],
          send:          %i[public_send __send__],
          to_a:          %i[to_ary],
          to_h:          %i[to_hash],
          to_i:          %i[to_int],
          to_s:          %i[to_str],
          values_at:     %i[fetch_values]
        }.freeze.tap { |hash| hash.values(&:freeze) }

        RECEIVER_SELECTOR_REPLACEMENTS = {
          Date: {
            parse: %i[jd civil strptime iso8601 rfc3339 xmlschema rfc2822 rfc822 httpdate jisx0301]
          }.freeze
        }.freeze

        REGEXP_MATCH_METHODS    = %i[=~ match match?].freeze
        REGEXP_START_WITH_NODES = %i[regexp_bos_anchor regexp_literal_literal].freeze
        REGEXP_END_WITH_NODES   = %i[regexp_literal_literal regexp_eos_anchor].freeze

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
          emit_reduce_to_sum_mutation
          emit_start_end_with_mutations
          emit_predicate_mutations
          emit_array_mutation
          emit_static_send
          emit_const_get_mutation
          emit_integer_mutation
          emit_dig_mutation
          emit_double_negation_mutation
          emit_lambda_mutation
        end

        def emit_reduce_to_sum_mutation
          return unless selector.equal?(:reduce)

          reducer = arguments.last

          return unless reducer.eql?(s(:sym, :+)) || reducer.eql?(s(:block_pass, s(:sym, :+)))

          if arguments.length > 1
            initial_value = arguments.first
            emit_type(receiver, :sum, initial_value)
          else
            emit_type(receiver, :sum)
          end
        end

        def emit_start_end_with_mutations # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
          return unless REGEXP_MATCH_METHODS.include?(selector) && arguments.one?

          argument = Mutant::Util.one(arguments)

          return unless argument.type.equal?(:regexp) && (
            regexp_ast = AST::Regexp.expand_regexp_ast(argument)
          )

          regexp_children = regexp_ast.children

          case regexp_children.map(&:type)
          when REGEXP_START_WITH_NODES
            emit_start_with(regexp_children)
          when REGEXP_END_WITH_NODES
            emit_end_with(regexp_children)
          end
        end

        def emit_start_with(regexp_nodes)
          literal = Mutant::Util.one(regexp_nodes.last.children)
          emit_type(receiver, :start_with?, s(:str, literal))
        end

        def emit_end_with(regexp_nodes)
          literal = Mutant::Util.one(regexp_nodes.first.children)
          emit_type(receiver, :end_with?, s(:str, literal))
        end

        def emit_predicate_mutations
          return unless selector.match?(/\?\z/) && !selector.equal?(:defined?)

          emit(s(:true))
          emit(s(:false))
        end

        def emit_array_mutation
          return unless selector.equal?(:Array) && possible_kernel_method?

          emit(s(:array, *arguments))
        end

        def emit_static_send
          return unless %i[__send__ send public_send].include?(selector)

          dynamic_selector, *actual_arguments = *arguments

          return unless dynamic_selector && n_sym?(dynamic_selector)

          method_name = AST::Meta::Symbol.new(dynamic_selector).name

          emit(s(node.type, receiver, method_name, *actual_arguments))
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
          emit(receiver) if receiver && !left_op_assignment?
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
          return unless arguments.one?

          argument = Mutant::Util.one(arguments)

          return if n_kwargs?(argument) || n_forwarded_args?(argument)

          emit_propagation(argument)
        end

        def mutate_receiver
          return unless receiver
          emit_implicit_self
          emit_explicit_self
          emit_receiver_mutations do |node|
            !n_nil?(node)
          end
        end

        def emit_explicit_self
          return if UNARY_METHOD_OPERATORS.include?(selector)

          emit_receiver(N_SELF) unless n_nil?(receiver)
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
