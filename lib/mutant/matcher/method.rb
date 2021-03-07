# frozen_string_literal: true

module Mutant
  class Matcher
    # Abstract base class for method matchers
    class Method < self
      include AbstractType,
              Adamantium,
              Concord::Public.new(:scope, :target_method, :evaluator)

      SOURCE_LOCATION_WARNING_FORMAT =
        '%s does not have a valid source location, unable to emit subject'

      CLOSURE_WARNING_FORMAT =
        '%s is dynamically defined in a closure, unable to emit subject'

      # Matched subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        evaluator.call(scope, target_method, env)
      end

      # Abstract method match evaluator
      #
      # Present to avoid passing the env argument around in case the
      # logic would be implemented directly on the Matcher::Method
      # instance
      class Evaluator
        include(
          AbstractType,
          Adamantium,
          Concord.new(:scope, :target_method, :env),
          Procto,
          AST::NodePredicates
        )

        # Matched subjects
        #
        # @return [Enumerable<Subject>]
        def call
          return EMPTY_ARRAY if skip?

          [subject].compact
        end

      private

        def skip?
          location = source_location

          file = location&.first

          if location.nil? || !file.end_with?('.rb')
            env.warn(SOURCE_LOCATION_WARNING_FORMAT % target_method)
          elsif matched_node_path.any?(&method(:n_block?))
            env.warn(CLOSURE_WARNING_FORMAT % target_method)
          end
        end

        def method_name
          target_method.name
        end

        def context
          Context.new(scope, source_path)
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
          target_method.source_location
        end

        def subject
          node = matched_node_path.last || return

          self.class::SUBJECT_CLASS.new(
            context: context,
            node:    node
          )
        end
        memoize :subject

        def matched_node_path
          AST.find_last_path(ast, &method(:match?))
        end
        memoize :matched_node_path
      end # Evaluator

      private_constant(*constants(false))

    end # Method
  end # Matcher
end # Mutant
