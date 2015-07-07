module Mutant
  class Matcher
    # Matcher for subjects that are a specific method
    class Method < self
      include Adamantium::Flat, Concord::Public.new(:env, :scope, :target_method)
      include AST::NodePredicates

      # Methods within rbx kernel directory are precompiled and their source
      # cannot be accessed via reading source location. Same for methods created by eval.
      BLACKLIST = %r{\Akernel/|(eval)}.freeze

      # Enumerate matches
      #
      # @return [Enumerable<Subject>]
      #   if no block given
      #
      # @return [self]
      #   otherwise
      #
      # @api private
      def each
        return to_enum unless block_given?

        if !skip? && subject
          yield subject
        end

        self
      end

    private

      # Test if method should be skipped
      #
      # @return [Boolean]
      #
      # @api private
      def skip?
        location = source_location
        if location.nil? || BLACKLIST.match(location.first)
          env.warn(format('%s does not have valid source location unable to emit subject', target_method.inspect))
          true
        elsif matched_node_path.any?(&method(:n_block?))
          env.warn(format('%s is defined from a 3rd party lib unable to emit subject', target_method.inspect))
          true
        else
          false
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
      # @return [String]
      #
      # @api private
      def source_path
        source_location.first
      end

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
        node = matched_node_path.last
        return unless node
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

    end # Method
  end # Matcher
end # Mutant
