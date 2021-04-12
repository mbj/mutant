# frozen_string_literal: true

module Mutant
  class Matcher
    # Abstract base class for matcher that returns method subjects from scope
    class Methods < self
      include AbstractType, Concord.new(:scope)

      CANDIDATE_NAMES = %i[
        public_instance_methods
        private_instance_methods
        protected_instance_methods
      ].freeze

      private_constant(*constants(false))

      # Enumerate subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        Chain.new(
          methods.map { |method| matcher.new(scope, method) }
        ).call(env)
      end

    private

      def matcher
        self.class::MATCHER
      end

      def methods
        candidate_names.each_with_object([]) do |name, methods|
          method = access(name)
          methods << method if method.owner.equal?(candidate_scope)
        end
      end
      memoize :methods

      def candidate_names
        CANDIDATE_NAMES
          .map(&candidate_scope.public_method(:public_send))
          .reduce(:+)
          .sort
      end

      abstract_method :candidate_scope
      private :candidate_scope

      # Matcher for singleton methods
      class Singleton < self
        MATCHER = Matcher::Method::Singleton

      private

        def access(method_name)
          scope.method(method_name)
        end

        def candidate_scope
          scope.singleton_class
        end

      end # Singleton

      # Matcher for metaclass methods
      class Metaclass < self
        MATCHER = Matcher::Method::Metaclass

      private

        def access(method_name)
          scope.method(method_name)
        end

        def candidate_scope
          scope.singleton_class
        end
      end # Metaclass

      # Matcher for instance methods
      class Instance < self
        MATCHER = Matcher::Method::Instance

      private

        def access(method_name)
          scope.instance_method(method_name)
        end

        def candidate_scope
          scope
        end

      end # Instance
    end # Methods
  end # Matcher
end # Mutant
