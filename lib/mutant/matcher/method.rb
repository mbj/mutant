module Mutant
  class Matcher
    # Matcher for subjects that are a specific method
    class Method < self
      include Adamantium::Flat, Concord::Public.new(:cache, :scope, :method)
      include Equalizer.new(:identification)

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
      #
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
      #
      def skip?
        location = source_location
        if location.nil? || BLACKLIST.match(location.first)
          message = format(
            '%s does not have valid source location unable to emit matcher',
            method.inspect
          )
          $stderr.puts(message)
          true
        else
          false
        end
      end

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      def method_name
        method.name
      end

      # Return context
      #
      # @return [Context::Scope]
      #
      # @api private
      #
      def context
        Context::Scope.new(scope, source_path)
      end

      # Return full ast
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def ast
        cache.parse(source_path)
      end

      # Return path to source
      #
      # @return [String]
      #
      # @api private
      #
      def source_path
        source_location.first
      end

      # Return source file line
      #
      # @return [Integer]
      #
      # @api private
      #
      def source_line
        source_location.last
      end

      # Return source location
      #
      # @return [Array]
      #
      # @api private
      #
      def source_location
        method.source_location
      end

      # Return subject
      #
      # @return [Subject]
      #   if there is a matched node
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def subject
        node = matched_node
        return unless node
        self.class::SUBJECT_CLASS.new(context, node)
      end
      memoize :subject

      # Return matched node
      #
      # @return [Parser::AST::Node]
      #   if node could be found
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def matched_node
        Finder.run(ast) do |node|
          match?(node)
        end
      end

    end # Method
  end # Matcher
end # Mutant
