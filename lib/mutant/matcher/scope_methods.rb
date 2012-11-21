module Mutant
  class Matcher
    # Abstract base class for matcher that returns subjects extracted from scope methods
    class ScopeMethods < self
      include AbstractClass

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
      # @param [UnboundMethod] method
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


      abstract_method :methods

      # Return method matcher class
      #
      # @return [Class:Matcher::Method]
      #
      # @api private
      #
      def matcher
        self.class::MATCHER
      end

      class Singleton < self
        MATCHER = Mutant::Matcher::Method::Singleton

      private

        # Return singleton methods defined on scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Symbol>]
        #
        # @api private
        #
        def methods
          singleton_class = scope.singleton_class

          names = 
            singleton_class.public_instance_methods(false)   +
            singleton_class.private_instance_methods(false)  +
            singleton_class.protected_instance_methods(false)

          names.map(&:to_sym).sort.reject do |name|
            name.to_sym == :__class_init__
          end
        end
      end

      class Instance < self
        MATCHER = Mutant::Matcher::Method::Instance

      private

        # Return instance methods names of scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Symbol>]
        #
        def methods
          scope = self.scope
          return [] unless scope.kind_of?(Module)

          names = 
            scope.public_instance_methods(false)  +
            scope.private_instance_methods(false) + 
            scope.protected_instance_methods(false)

          names.uniq.map(&:to_sym).sort
        end
      end
    end
  end
end
