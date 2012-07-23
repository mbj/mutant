module Mutant
  class Matcher 
    class Method < Matcher
      # A instance method filter
      class Instance < Method
      private
        # Return method instance
        # 
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          constant.instance_method(method_name)
        end

        # Return matched node class 
        # 
        # @return [Rubinius::AST::Define]
        #
        # @api private
        #
        def node_class
          Rubinius::AST::Define
        end
      end
    end
  end
end
