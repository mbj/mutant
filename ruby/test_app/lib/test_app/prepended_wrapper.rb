# frozen_string_literal: true

module TestApp
  module PrependedWrapperTests
    PublicWrapper = Module.new do
      def foo; end
    end

    ProtectedWrapper = Module.new do
      def foo; end
      protected :foo
    end

    PrivateWrapper = Module.new do
      def foo; end
      private :foo
    end

    class WithPrivateMethod
      prepend PublicWrapper

    private

      def foo; end
    end

    class WithPublicMethod
      prepend ProtectedWrapper

      def foo; end
    end

    module WithModuleFunction
      singleton_class.prepend(PublicWrapper)

    module_function

      def foo; end
    end

    module WithPublicModuleFunction
      def foo; end
      module_function :foo
      public :foo
      prepend PrivateWrapper
    end

    module WithPrivateModuleFunctionCopy
      def foo; end
      module_function :foo
      private_class_method :foo
      singleton_class.prepend(PublicWrapper)
    end

    class WithPrivateSingletonMethod
      singleton_class.prepend(PublicWrapper)

      def self.foo; end
      private_class_method :foo
    end

    class WithPublicSingletonMethod
      singleton_class.prepend(ProtectedWrapper)

      def self.foo; end
    end
  end
end
