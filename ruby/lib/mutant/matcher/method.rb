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
          T::Private::Methods.signature_for_method(target_method)
        end

        def subject_config(node)
          Subject::Config.parse(
            comments: ast.comment_associations.fetch(node, []),
            mutation: env.config.mutation
          )
        end

        def matched_view
          return if source_location.nil?

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

        def visibility
          if scope.raw.private_methods.include?(method_name)
            :private
          elsif scope.raw.protected_methods.include?(method_name)
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
