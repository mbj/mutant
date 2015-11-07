module Mutant
  class Matcher
    # Abstract base class for method matchers
    class Method < self
      include AbstractType,
              Adamantium::Flat,
              Concord::Public.new(:scope, :target_method, :evaluator)

      # Methods within rbx kernel directory are precompiled and their source
      # cannot be accessed via reading source location. Same for methods created by eval.
      BLACKLIST = %r{\A(kernel/|\(eval\)\z)}.freeze

      SOURCE_LOCATION_WARNING_FORMAT =
        '%s does not have a valid source location, unable to emit subject'.freeze

      CLOSURE_WARNING_FORMAT =
        '%s is dynamically defined in a closure, unable to emit subject'.freeze

      # Matched subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(env)
        evaluator.call(scope, target_method, env)
      end

      # Abstract method match evaluator
      #
      # Present to avoid passing the env argument around in case the
      # logic would be implemnented directly on the Matcher::Method
      # instance
      class Evaluator
        include AbstractType,
                Adamantium,
                Concord.new(:scope, :target_method, :env),
                Procto.call,
                AST::NodePredicates

        # Matched subjects
        #
        # @return [Enumerable<Subject>]
        #
        # @api private
        def call
          return EMPTY_ARRAY if skip?

          [subject].compact
        end

      private

        # Test if method should be skipped
        #
        # @return [Truthy]
        #
        # @api private
        def skip?
          location = source_location
          if location.nil? || BLACKLIST.match(location.first)
            env.warn(SOURCE_LOCATION_WARNING_FORMAT % target_method)
          elsif matched_node_path.any?(&method(:n_block?))
            env.warn(CLOSURE_WARNING_FORMAT % target_method)
          end
        end

        # Target method name
        #
        # @return [String]
        #
        # @api private
        def method_name
          target_method.name
        end

        # Target context
        #
        # @return [Context::Scope]
        #
        # @api private
        def context
          Context::Scope.new(scope, source_path)
        end

        # Root source node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        def ast
          env.cache.parse(source_path)
        end

        # Path to source
        #
        # @return [Pathname]
        #
        # @api private
        def source_path
          Pathname.new(source_location.first)
        end
        memoize :source_path

        # Source file line
        #
        # @return [Fixnum]
        #
        # @api private
        def source_line
          source_location.last
        end

        # Full source location
        #
        # @return [Array{String,Fixnum}]
        #
        # @api private
        def source_location
          target_method.source_location
        end

        # Matched subject
        #
        # @return [Subject]
        #   if there is a matched node
        #
        # @return [nil]
        #   otherwise
        #
        # @api private
        def subject
          node = matched_node_path.last || return
          self.class::SUBJECT_CLASS.new(context, node)
        end
        memoize :subject

        # Matched node path
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        def matched_node_path
          AST.find_last_path(ast, &method(:match?))
        end
        memoize :matched_node_path
      end # Evaluator

      private_constant(*constants(false))

    end # Method
  end # Matcher
end # Mutant
