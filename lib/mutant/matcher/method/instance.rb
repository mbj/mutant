module Mutant
  class Matcher 
    class Method < Matcher
      # A instance method filter
      class Instance < Method
      private
        def method
          constant.instance_method(method_name)
        end

        def node_class
          Rubinius::AST::Define
        end
      end
    end
  end
end
