module Mutant
  class Matcher
    # Matcher for subjects that are a specific method
    class Method < self
      include Adamantium::Flat, Concord::Public.new(:cache, :scope, :method)

      # Methods within rbx kernel directory are precompiled and their source
      # cannot be accessed via reading source location
      SKIP_METHODS = %w[kernel/ (eval)].freeze
      BLACKLIST    = /\A#{Regexp.union(*SKIP_METHODS)}/.freeze

      # Enumerate matches
      #
      # @return [Enumerable<Subject>]
      #   returns enumerable when no block given
      #
      # @return [self]
      #   returns self when block given
      #
      # @api private
      #
      def each
        return to_enum unless block_given?

        unless skip?
          if subject
            yield subject
          else
            message = sprintf(
              'Cannot find definition of: %s in %s',
              identification,
              source_location.join(':')
            )
            $stderr.puts(message)
          end
        end

        self
      end

    private

      # Test if method is skipped
      #
      # @return [true]
      #   true and print warning if location must be filtered
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def skip?
        location = source_location
        if location.nil? or BLACKLIST.match(location.first)
          message = sprintf(
            '%s does not have valid source location unable to emit matcher',
            method.inspect
          )
          $stderr.puts(message)
          return true
        end

        false
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
      #   returns subject if there is a matched node
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
