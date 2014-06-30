module Mutant
  class Matcher
    # Abstract base class for matcher that returns method subjects from scope
    class Methods < self
      include AbstractType, Concord::Public.new(:cache, :scope)

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        subjects.each(&block)

        self
      end

      # Return method matcher class
      #
      # @return [Class:Matcher::Method]
      #
      # @api private
      #
      def matcher
        self.class::MATCHER
      end

      # Return methods
      #
      # @return [Enumerable<Method, UnboundMethod>]
      #
      # @api private
      #
      def methods
        candidate_names.each_with_object([]) do |name, methods|
          method = access(name)
          methods << method if method.owner.equal?(candidate_scope)
        end
      end
      memoize :methods

    private

      # Return subjects
      #
      # @return [Array<Subject>]
      #
      # @api private
      #
      def subjects
        methods.map do |method|
          matcher.build(cache, scope, method)
        end.flat_map(&:to_a)
      end
      memoize :subjects

      # Return candidate names
      #
      # @param [Object] object
      #
      # @return [Enumerable<Symbol>]
      #
      # @api private
      #
      def candidate_names
        (
          candidate_scope.public_instance_methods(false)   +
          candidate_scope.private_instance_methods(false)  +
          candidate_scope.protected_instance_methods(false)
        ).sort
      end

      # Return candidate scope
      #
      # @return [Class, Module]
      #
      # @api private
      #
      abstract_method :candidate_scope

      # Matcher for singleton methods
      class Singleton < self
        MATCHER = Matcher::Method::Singleton

      private

        # Return method for name
        #
        # @param [Symbol] method_name
        #
        # @return [Method]
        #
        # @api private
        #
        def access(method_name)
          scope.method(method_name)
        end

        # Return candidate scope
        #
        # @return [Class]
        #
        # @api private
        #
        def candidate_scope
          scope.singleton_class
        end
        memoize :candidate_scope, freezer: :noop

      end # Singleton

      # Matcher for instance methods
      class Instance < self
        MATCHER = Matcher::Method::Instance

      private

        # Return method for name
        #
        # @param [Symbol] method_name
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def access(method_name)
          scope.instance_method(method_name)
        end

        # Return candidate scope
        #
        # @return [Class, Module]
        #
        # @api private
        #
        def candidate_scope
          scope
        end

      end # Instance

    end # Methods
  end # Matcher
end # Mutant
