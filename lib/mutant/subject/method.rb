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

      # Return method name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def name
        node.name
      end

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

      # Instance method subjects
      class Instance < self

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

        # Return subtype identifier
        #
        # @return [String]
        #
        # @api private
        #
        def subtype
          "#{context.identification}##{name}"
        end

      end

      # Singleton method subjects
      class Singleton < self

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

      private

        # Return subtype identifier
        #
        # @return [String]
        #
        # @api private
        #
        def subtype
          "#{context.identification}.#{node.body.name}"
        end
      end
    end
  end
end
