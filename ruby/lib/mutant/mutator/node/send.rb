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

        RECEIVER_SELECTOR_REPLACEMENTS = {
          Date: {
            parse: %i[jd civil strptime iso8601 rfc3339 xmlschema rfc2822 rfc822 httpdate jisx0301]
          }.freeze
        }.freeze

        REGEXP_MATCH_METHODS = %i[=~ match match?].freeze

        REGEXP_START_WITH_NODES =
          [
            ::Regexp::Expression::Anchor::BeginningOfString,
            ::Regexp::Expression::Literal
          ].freeze

        REGEXP_END_WITH_NODES =
          [
            ::Regexp::Expression::Literal,
            ::Regexp::Expression::Anchor::EndOfString
          ].freeze

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
          AST::Meta::Send.new(node:)
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
          emit_type_coercion_mutations
          emit_static_send
          emit_const_get_mutation
          emit_dig_mutation
          emit_double_negation_mutation
          emit_lambda_mutation
        end

        def emit_type_coercion_mutations
          emit_array_mutation
          emit_integer_mutation
          emit_empty_collection_mutation
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

        def emit_start_end_with_mutations
          return unless REGEXP_MATCH_METHODS.include?(selector) && arguments.one?

          argument = Mutant::Util.one(arguments)

          return unless argument.type.equal?(:regexp)

          emit_regexp_to_prefix_suffix(argument)
        end

        def emit_regexp_to_prefix_suffix(argument)
          string = Regexp.regexp_body(argument) or return

          expressions = ::Regexp::Parser.parse(string)

          case expressions.map(&:class)
          when REGEXP_START_WITH_NODES
            emit_start_with(expressions.last.text)
          when REGEXP_END_WITH_NODES
            emit_end_with(expressions.first.text)
          end
        end

        def emit_start_with(string)
          emit_type(receiver, :start_with?, s(:str, string))
        end

        def emit_end_with(string)
          emit_type(receiver, :end_with?, s(:str, string))
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

          method_name = AST::Meta::Symbol.new(node: dynamic_selector).name

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

          negated = AST::Meta::Send.new(node: receiver)
          emit(negated.receiver) if negated.selector.equal?(:!)
        end

        def emit_lambda_mutation
          emit(s(:send, nil, :lambda)) if meta.proc?
        end

        def emit_empty_collection_mutation
          case selector
          when :to_a, :to_ary
            emit(s(:array))
          when :to_h, :to_hash
            emit(s(:hash))
          when :to_s, :to_str
            emit(s(:str, ''))
          end
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

          emit(s(:const, receiver, AST::Meta::Symbol.new(node: arguments.first).name))
        end

        def emit_selector_replacement
          config
            .operators
            .selector_replacements
            .fetch(selector, EMPTY_ARRAY).each(&public_method(:emit_selector))
        end

        def emit_naked_receiver
          emit(receiver) if receiver && !left_op_assignment?
        end

        def mutate_arguments
          emit_type(receiver, selector)
          remaining_children_indices.each do |index|
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

          return if n_kwargs?(argument) || n_forwarded_args?(argument) || n_forwarded_restarg?(argument)

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
