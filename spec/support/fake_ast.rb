unless defined?(Rubinius)
  module Rubinius
    # Dummy AST namespace
    module AST
      # Dummy node
      class Node
        attr_reader :line, :name

        attr_accessor :body

        def initialize(line, name, body=[])
          @line, @name, @body = line, name, body
        end
      end

      class ConstantScope < Node
      end

      class ClassScope < ConstantScope
      end

      class ModuleScope < ConstantScope
      end

      class Script < Node
      end

      # Dummy class node
      class Class < Node
        def initialize(line, name, superclass, body)
          super(line, name)
          @superclass, @body = superclass, body
        end
      end

      # Dummy module node
      class Module < Node
        def initialize(line, name, body)
          super(line, name)
          @body = body
        end
      end

      class ConstantAccess < Node
      end
    end
  end
end
