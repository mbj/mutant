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
          scope.public_method_defined?(method_name)
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
          "#{context.identification}##{node.name}"
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
          scope.singleton_class.public_method_defined?(method_name)
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
