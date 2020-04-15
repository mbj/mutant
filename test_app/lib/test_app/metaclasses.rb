# frozen_string_literal: true

module TestApp
  module MetaclassMethodTests
    module DefinedOnSelf
      class << self
        def foo; end
      end
    end

    module DefinedOnLvar
      a = self
      class << a
        def foo; end
      end
    end

    module DefinedOnConstant
      module InsideNamespace
        class << InsideNamespace
          def foo; end
        end
      end

      module OutsideNamespace
      end

      class << OutsideNamespace
        def foo
        end
      end
    end

    module DefinedMultipleTimes
      module DifferentLines
        class << self
          def foo
          end

          def foo(_arg)
          end
        end
      end

      module SameLine
        module SameScope
          class << self
            def foo; end; def foo(_arg); end
          end
        end

        module DifferentScope
          class << self; def foo; end; end; class << DifferentScope; def foo(_arg); end; end; class << MetaclassMethodTests; def foo; end; end
        end

        module DifferentName
          class << self; def foo; end; def bar(_arg); end; end
        end
      end
    end
  end
end
