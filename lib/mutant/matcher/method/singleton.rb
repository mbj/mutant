module Mutant
  class Matcher
    class Method
      # A singleton method filter
      class Singleton < Method
      private
        def method
          constant.method(method_name)
        end

        def node_class
          Rubinius::AST::DefineSingleton
        end
      end
    end
  end
end
