module Mutant
  class Subject
    # Abstract base class for method subjects
    class Method < self

      # Test if method is public
      #
      # @return [true]
      #   if method is public
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      abstract_method :public?

    private

      # Return scope
      #
      # @return [Class, Module]
      #
      # @api private
      #
      def scope
        context.scope
      end

      # Return method name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def name
        node.children[self.class::NAME_INDEX]
      end

      # Return subtype identifier
      #
      # @return [String]
      #
      # @api private
      #
      def subtype
        "#{context.identification}#{self.class::SYMBOL}#{name}"
      end

      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL = '#'.freeze

        # Test if method is public
        #
        # @return [true]
        #   if method is public
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def public?
          scope.public_method_defined?(name)
        end
        memoize :public?

      private

      end # Instance

      # Singleton method subjects
      class Singleton < self

        NAME_INDEX = 1
        SYMBOL = '.'.freeze

        # Test if method is public
        #
        # @return [true]
        #   if method is public
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def public?
          scope.singleton_class.public_method_defined?(name)
        end
        memoize :public?

      end # Singleton

    end # Method
  end # Subject
end # Mutant
