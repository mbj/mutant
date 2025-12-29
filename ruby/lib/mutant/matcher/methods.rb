# frozen_string_literal: true

module Mutant
  class Matcher
    # Abstract base class for matcher that returns method subjects from scope
    class Methods < self
      include AbstractType, Anima.new(:scope)

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
          matchers: methods(env).map do |target_method|
            matcher.new(scope:, target_method:)
          end
        ).call(env)
      end

    private

      def matcher
        self.class::MATCHER
      end

      def methods(env)
        candidate_names.each_with_object([]) do |name, methods|
          method = access(env, name)
          methods << method if method
        end
      end

      def candidate_names
        CANDIDATE_NAMES
          .map { |name| candidate_scope.public_send(name, false) }
          .reduce(:+)
          .sort
      end

      abstract_method :candidate_scope
      private :candidate_scope

      # Matcher for singleton methods
      class Singleton < self
        MATCHER = Matcher::Method::Singleton

      private

        def access(_env, method_name)
          scope.raw.method(method_name)
        end

        def candidate_scope
          scope.raw.singleton_class
        end

      end # Singleton

      # Matcher for metaclass methods
      class Metaclass < self
        MATCHER = Matcher::Method::Metaclass

      private

        def access(_env, method_name)
          scope.raw.method(method_name)
        end

        def candidate_scope
          scope.raw.singleton_class
        end
      end # Metaclass

      # Matcher for instance methods
      class Instance < self
        MATCHER = Matcher::Method::Instance

        MESSAGE = <<~'MESSAGE'
          Caught an exception while accessing a method with
          #instance_method that is part of #{public,private,protected}_instance_methods.

          This is a bug in your ruby implementation, its stdlib, your dependencies, or your code.

          Mutant will ignore this method:

          Object:    %<scope>s
          Method:    %<method_name>s
          Exception:

          %<exception>s

          See: https://github.com/mbj/mutant/issues/1273
        MESSAGE

      private

        def access(env, method_name)
          candidate_scope.instance_method(method_name)
        rescue => exception
          env.warn(
            MESSAGE % { scope:, method_name:, exception: exception.inspect }
          )
          nil
        end

        def candidate_scope
          scope.raw
        end

      end # Instance
    end # Methods
  end # Matcher
end # Mutant
