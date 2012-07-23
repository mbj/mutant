module Mutant
  class Matcher
    class Method
      # A singleton method filter
      class Singleton < Method
      private
        # Return method instance
        # 
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          constant.method(method_name)
        end

        # Return matched node class 
        # 
        # @return [Rubinius::AST::Define]
        #
        # @api private
        #
        def node_class
          Rubinius::AST::DefineSingletonScope
        end
      end
    end
  end
end
