module Mutant
  class Matcher
    # Abstract base class for matcher that returns method subjects from scope
    class Methods < self
      include AbstractType, Concord.new(:scope)

      CANDIDATE_NAMES = IceNine.deep_freeze(%i[
        public_instance_methods
        private_instance_methods
        protected_instance_methods
      ])

      private_constant(*constants(false))

      # Enumerate subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(env)
        Chain.new(
          methods.map { |method| matcher.new(scope, method) }
        ).call(env)
      end

    private

      # method matcher class
      #
      # @return [Class:Matcher::Method]
      #
      # @api private
      def matcher
        self.class::MATCHER
      end

      # Available methods scope
      #
      # @return [Enumerable<Method, UnboundMethod>]
      #
      # @api private
      def methods
        candidate_names.each_with_object([]) do |name, methods|
          method = access(name)
          methods << method if method.owner.equal?(candidate_scope)
        end
      end
      memoize :methods

      # Candidate method names on target scope
      #
      # @return [Enumerable<Symbol>]
      #
      # @api private
      def candidate_names
        CANDIDATE_NAMES
          .map(&candidate_scope.method(:public_send))
          .reduce(:+)
          .sort
      end

      # Candidate scope
      #
      # @return [Class, Module]
      #
      # @api private
      abstract_method :candidate_scope

      # Matcher for singleton methods
      class Singleton < self
        MATCHER = Matcher::Method::Singleton

      private

        # Method object on scope
        #
        # @param [Symbol] method_name
        #
        # @return [Method]
        #
        # @api private
        def access(method_name)
          scope.method(method_name)
        end

        # Candidate scope
        #
        # @return [Class]
        #
        # @api private
        def candidate_scope
          scope.singleton_class
        end
        memoize :candidate_scope, freezer: :noop

      end # Singleton

      # Matcher for instance methods
      class Instance < self
        MATCHER = Matcher::Method::Instance

      private

        # Method object on scope
        #
        # @param [Symbol] method_name
        #
        # @return [UnboundMethod]
        #
        # @api private
        def access(method_name)
          scope.instance_method(method_name)
        end

        # Candidate scope
        #
        # @return [Class, Module]
        #
        # @api private
        def candidate_scope
          scope
        end

      end # Instance
    end # Methods
  end # Matcher
end # Mutant
