module Mutant
  class Matcher
    # Abstract base class for matcher that returns method subjects extracted from scope
    class Methods < self
      include AbstractType, Concord.new(:scope)

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

        methods.each do |method|
          emit_matches(method, &block)
        end

        self
      end

    private

      # Return method matcher class
      #
      # @return [Class:Matcher::Method]
      #
      # @api private
      #
      def matcher
        self.class::MATCHER
      end

      # Emit matches for method
      #
      # @param [UnboundMethod, Method] method
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_matches(method)
        matcher.new(scope, method).each do |subject|
          yield subject
        end
      end

      # Return methods
      #
      # @return [Enumerable<Method, UnboundMethod>]
      #
      # @api private
      #
      def methods
        candidates.each_with_object([]) do |name, methods|
          method = access(name)
          methods << method if method.owner == scope
        end
      end
      memoize :methods

      # Return candidate names
      #
      # @param [Object] object
      #
      # @return [Enumerable<Symbol>]
      #
      # @api private
      #
      def candidates
        object = self.scope
        names = 
          object.public_instance_methods(false)   +
          object.private_instance_methods(false)  +
          object.protected_instance_methods(false)
        names.sort
      end

      class Singleton < self
        MATCHER = Matcher::Method::Singleton

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

      private

        # Return singleton methods defined on scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Symbol>]
        #
        # @api private
        #
        def method_names
          singleton_class = scope.singleton_class
          candidate_names.sort.reject do |name|
            name.to_sym == :__class_init__
          end
        end
      end

      class Instance < self
        MATCHER = Matcher::Method::Instance

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

      private

        # Return instance methods names of scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Symbol>]
        #
        # @api private
        #
        def method_names
          scope = self.scope
          return [] unless scope.kind_of?(Module)
          candidate_names.sort
        end
      end
    end
  end
end
