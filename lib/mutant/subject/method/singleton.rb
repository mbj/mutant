module Mutant
  class Subject
    class Method
      # Singleton method subjects
      class Singleton < self

        NAME_INDEX = 1
        SYMBOL     = '.'.freeze

        # Test if method is public
        #
        # @return [Boolean]
        #
        # @api private
        def public?
          scope.singleton_class.public_method_defined?(name)
        end
        memoize :public?

        # Prepare subject for mutation insertion
        #
        # @return [self]
        #
        # @api private
        def prepare
          scope.singleton_class.__send__(:undef_method, name)
          self
        end

      end # Singleton
    end # Method
  end # Subject
end # Mutant
