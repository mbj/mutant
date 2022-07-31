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

          if matched_view.path.any?(&:block.public_method(:equal?))
            env.warn(CLOSURE_WARNING_FORMAT % target_method)

            return EMPTY_ARRAY
          end

          [subject]
        end

        def subject
          self.class::SUBJECT_CLASS.new(
            config:     subject_config(matched_view.node),
            context:    context,
            node:       matched_view.node,
            visibility: visibility
          )
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

          ast
            .on_line(source_line)
            .select { |view| view.node.type.eql?(self.class::MATCH_NODE_TYPE) && match?(view.node) }
            .last
        end
        memoize :matched_view

        def visibility
          # This can be cleaned up once we are on >ruby-3.0
          # Method#{public,private,protected}? exists there.
          #
          # On Ruby 3.1 this can just be:
          #
          # if target_method.private?
          #   :private
          # elsif target_method.protected?
          #   :protected
          # else
          #   :public
          # end
          #
          # Change to this once 3.0 is EOL.
          if scope.private_methods.include?(method_name)
            :private
          elsif scope.protected_methods.include?(method_name)
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
