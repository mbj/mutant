# frozen_string_literal: true

module TestApp
  module MetaclassMethodTests
    module DefinedOnSelf
      class << self
        def foo; end
      end

      # again this is a weird edge-case that's being checked for consistent
      # behaviour, not something that people ought to be doing.
      module InsideMetaclass
        class << self
          # some older versions of ruby don't have Object#singleton_class,
          # this is just an implementation of that so we can grab
          # InsideMetaclass.metaclass for use as the scope object
          def metaclass
            class << self
              self
            end
          end

          # InsideMetaclass.foo
          def foo; end

          class << self
            # #<Class:InsideMetaclass>.foo
            def foo; end
          end
        end
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
