module Mutant
  class Subject
    class Method
      # Singleton method subjects
      class Singleton < self

        NAME_INDEX = 1
        SYMBOL     = '.'.freeze

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          scope.singleton_class.__send__(:undef_method, name)
          self
        end

      end # Singleton
    end # Method
  end # Subject
end # Mutant
