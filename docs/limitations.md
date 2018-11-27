Limitations
===========

Subject
-------

Mutant cannot emit mutations for some subjects.

* methods defined within a closure.  For example, methods defined using `module_eval`, `class_eval`,
  `define_method`, or `define_singleton_method`:

    ```ruby
    class Example
      class_eval do
        def example1
        end
      end

      module_eval do
        def example2
        end
      end

      define_method(:example3) do
      end

      define_singleton_method(:example4) do
      end
    end
    ```

* singleton methods not defined on a constant or `self`

    ```ruby
    class Foo
      def self.bar; end   # ok
      def Foo.baz; end    # ok

      myself = self
      def myself.qux; end # cannot mutate
    end
    ```

* methods defined with eval:

    ```ruby
    class Foo
      class_eval('def bar; end') # cannot mutate
    end
    ```
