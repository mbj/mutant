# frozen_string_literal: true

module Mutant
  class Subject
    class Method
      # Singleton method defined using metaclass syntax (class << self)
      class SingletonMetaclass < self

        NAME_INDEX = 0
        SYMBOL     = '.'

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          scope.singleton_class.__send__(:undef_method, name)
          self
        end
      end # SingletonMetaclass
    end # Method
  end # Subject
end # Mutant
