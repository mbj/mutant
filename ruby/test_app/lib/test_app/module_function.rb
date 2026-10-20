# frozen_string_literal: true

module TestApp
  module InstanceMethodTests
    module WithModuleFunction
    module_function

      def foo; end
    end

    module WithPrivateClassMethodModuleFunction
      def foo; end
      module_function :foo
      private_class_method :foo
    end

    module WithExtendSelf
      extend self

      def foo; end
    end

    module WithSeparateSingletonMethod
      def foo; end
      private :foo

      def self.foo; end
    end
  end
end
