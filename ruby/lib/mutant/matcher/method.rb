# frozen_string_literal: true

module Mutant
  class Matcher
    # Abstract base class for method matchers
    class Method < self
      include AbstractType,
              Adamantium,
              Anima.new(:scope, :target_method, :evaluator)

      SOURCE_LOCATION_WARNING_FORMAT =
        '%s does not have a valid source location, unable to emit subject'

      CLOSURE_WARNING_FORMAT =
        '%s is dynamically defined in a closure, unable to emit subject'

      CONSTANT_SCOPES = {
        class:  Context::ConstantScope::Class,
        module: Context::ConstantScope::Module
      }.freeze

      # Find the definition owned by a module
      #
      # A prepended module, such as the one the memosa gem uses for memoized
      # methods, can wrap a method and call super. Reflection returns that
      # wrapper, but the subject is the method defined on the module itself.
      # Returns nil when the module does not define the method, for example
      # on methods DelegateClass lists as its own.
      #
      # @param [Method, UnboundMethod] method
      # @param [Module] owner
      #
      # @return [Method, UnboundMethod, nil]
      def self.own_method(method, owner)
        method = method.super_method until method.nil? || method.owner.equal?(owner)
        method
      end

      # Matched subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        evaluator.call(scope:, target_method:, env:)
      end

      # Abstract method match evaluator
      #
      # Present to avoid passing the env argument around in case the
      # logic would be implemented directly on the Matcher::Method
      # instance
      #
      class Evaluator
        include(
          AbstractType,
          Adamantium,
          Anima.new(:scope, :target_method, :env),
          Procto,
          AST::NodePredicates
        )

        # Matched subjects
        #
        # @return [Enumerable<Subject>]
        def call
          location = source_location

          if location.nil? || !location.first.end_with?('.rb')
            env.warn(SOURCE_LOCATION_WARNING_FORMAT % target_method)

            return EMPTY_ARRAY
          end

          match_view
        end

      private

        def match_view
          return EMPTY_ARRAY if matched_view.nil?

          if matched_view.stack.any? { |node| node.type.equal?(:block) }
            env.warn(CLOSURE_WARNING_FORMAT % target_method)

            return EMPTY_ARRAY
          end

          [subject]
        end

        def subject
          self.class::SUBJECT_CLASS.new(
            config:     subject_config(matched_view.node),
            context:,
            node:       matched_view.node,
            visibility:
          )
        end

        def method_name
          target_method.name
        end

        def context
          Context.new(constant_scope:, scope:, source_path:)
        end

        # rubocop:disable Metrics/MethodLength
        def constant_scope
          matched_view
            .stack
            .reverse
            .reduce(Context::ConstantScope::None.new) do |descendant, node|
              klass = CONSTANT_SCOPES[node.type]

              if klass
                klass.new(
                  const:      node.children.fetch(0),
                  descendant:
                )
              else
                descendant
              end
          end
        end

        def ast
          env.parser.call(source_path)
        end

        def source_path
          env.world.pathname.new(source_location.first)
        end
        memoize :source_path

        def source_line
          source_location.last
        end

        def source_location
          signature = sorbet_signature

          if signature
            signature.method.source_location
          else
            target_method.source_location
          end
        end

        def sorbet_signature
          T::Private::Methods.signature_for_method(target_method) || prepended_sorbet_signature
        end

        def prepended_sorbet_signature
          method = target_method.owner.instance_method(method_name)

          until method.owner.equal?(target_method.owner)
            signature = T::Private::Methods.signature_for_method(method)
            return signature if signature && signature.owner.equal?(target_method.owner)

            method = method.super_method
          end
        end

        def subject_config(node)
          Subject::Config.parse(
            comments: ast.comment_associations.fetch(node, []),
            mutation: env.config.mutation
          )
        end

        def matched_view
          # This is a performance optimization when using --since to avoid the cost of parsing
          # every source file that could possibly map to a subject. A more fine-grained filtering
          # takes places later in the process.
          return unless relevant_source_file?

          ast
            .on_line(source_line)
            .select { |view| view.node.type.eql?(self.class::MATCH_NODE_TYPE) && match?(view.node) }
            .last
        end
        memoize :matched_view

        def relevant_source_file?
          env.config.matcher.diffs.all? { |diff| diff.touches_path?(source_path) }
        end

        # Ignore ancestors, as a prepended wrapper can have a different visibility
        def visibility
          singleton = scope.raw.singleton_class

          if singleton.private_method_defined?(method_name, false)
            :private
          elsif singleton.protected_method_defined?(method_name, false)
            :protected
          else
            :public
          end
        end
      end # Evaluator

      private_constant(*constants(false))

    end # Method
  end # Matcher
end # Mutant
