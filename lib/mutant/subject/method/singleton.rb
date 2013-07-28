# encoding: utf-8

module Mutant
  class Subject
    class Method
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
