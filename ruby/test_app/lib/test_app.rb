original = $VERBOSE
# Silence intentional violations made to exercise the method matcher edge cases.
# This is NOT representative for could you should write!
$VERBOSE = false
# Namespace for test application
module TestApp
  Adamantium = Mutant::Adamantium

  module InstanceMethodTests
    module WithMemoizer
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

  def self.root
    File.expand_path('..', __dir__)
  end

  module InstanceMethodTests
    class WithSignature
      extend T::Sig

      sig { void }
      def foo
      end
    end
  end

  module SingletonMethodTests
    class WithSignature
      extend T::Sig

      sig { void }
      def self.foo
      end
    end
  end

  require 'delegate'

  class DelegateTest < DelegateClass(String)
    def foo; end
  end

  class Foo
    class Bar < self
      class Baz < self
        def foo
        end
      end
    end
  end

  class InlineDisabled
    # mutant:disable
    def foo
    end

    # mutant:disable
    def self.foo
    end
  end

  ROOT = Pathname.new(__dir__).parent
end

require 'test_app/metaclasses'
require 'test_app/literal'
$VERBOSE = original
