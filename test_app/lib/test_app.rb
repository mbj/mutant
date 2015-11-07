require 'adamantium'

original = $VERBOSE
# Silence intentional violations made to exercise the method matcher edge cases.
# This is NOT representative for could you should write!
$VERBOSE = false
# Namespace for test application
module TestApp
  module InstanceMethodTests
    class WithMemoizer
      include Adamantium

      def bar; end; def baz; end
      eval('def boz; end')
      def foo; end;
      memoize :foo
    end

    module DefinedMultipleTimes
      class DifferentLines
        def foo
        end

        def foo(_arg)
        end
      end

      class SameLineSameScope
        def foo; end; def foo(_arg); end
      end

      class SameLineDifferentScope
        def self.foo; end; def foo(_arg); end
      end
    end

    class InClassEval
      class_eval do
        def foo
        end
      end
    end

    class InModuleEval
      module_eval do
        def foo
        end
      end
    end

    class InInstanceEval
      module_eval do
        def foo
        end
      end
    end
  end

  module SingletonMethodTests
    module DefinedOnSelf
      def self.foo; end
    end

    module DefinedOnLvar
      a = self
      def a.foo; end
    end

    module DefinedOnConstant
      module InsideNamespace
        def InsideNamespace.foo
        end
      end

      module OutsideNamespace
      end

      def OutsideNamespace.foo
      end
    end

    module DefinedMultipleTimes
      module DifferentLines
        def self.foo
        end

        def self.foo(_arg)
        end
      end

      module SameLine
        module SameScope
          def self.foo; end; def self.foo(_arg); end
        end

        module DifferentScope
          def self.foo; end; def DifferentScope.foo(_arg); end; def SingletonMethodTests.foo; end
        end

        module DifferentName
          def self.foo; end; def self.bar(_arg); end
        end
      end
    end
  end
end

require 'test_app/literal'
$VERBOSE = original
