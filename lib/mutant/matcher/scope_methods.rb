module Mutant
  class Matcher
    # Abstract base class for matcher that returns subjects extracted from scope methods
    class ScopeMethods < self
      include AbstractType

      # Return scope
      #
      # @return [Class,Model]
      #
      # @api private
      #
      attr_reader :scope

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

      # Return methods
      #
      # @return [Enumerable<Method, UnboundMethod>]
      #
      # @api private
      #
      def methods
        method_names.map do |name|
          access(name)
        end
      end
      memoize :methods

      # Return method matcher class
      #
      # @return [Class:Matcher::Method]
      #
      # @api private
      #
      def matcher
        self.class::MATCHER
      end

      # Return method names
      #
      # @param [Object] object
      #
      # @return [Enumerable<Symbol>]
      #
      # @api private
      #
      def self.method_names(object)
        object.public_instance_methods(false)   +
        object.private_instance_methods(false)  +
        object.protected_instance_methods(false)
      end

    private

      # Initialize object
      #
      # @param [Class,Module] scope
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(scope)
        @scope = scope
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

      # Return method names
      #
      # @return [Enumerable<Symbol>] 
      #
      # @api private
      #
      abstract_method :method_names

      class Singleton < self
        MATCHER = Mutant::Matcher::Method::Singleton

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
          names = self.class.method_names(singleton_class)

          names.sort.reject do |name|
            name.to_sym == :__class_init__
          end
        end
      end

      class Instance < self
        MATCHER = Mutant::Matcher::Method::Instance

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
          names = self.class.method_names(scope)
          names.uniq.sort
        end
      end
    end
  end
end
