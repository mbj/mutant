module Mutant
  # Base class for code loaders
  class Loader
    include AbstractClass
    extend MethodObject

  private

    # Run the loader
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :run

    # Initialize and insert mutation into vm
    #
    # @param [Rubinius::AST::Script] root
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(root)
      @root = Helper.deep_clone(root)
      run
    end

    # Eval based loader
    class Eval < self
      private

      # Run loader
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        eval(source, TOPLEVEL_BINDING)
      end

      # Return source
      #
      # @return [String]
      #
      # @api private
      #
      def source
        ToSource.to_source(@root)
      end
    end

    # Rubinius script node based loaded
    class Rubinius < self
      private

      # Run loader
      #
      # @return [undefined]
      #
      # @api private
      #
      def run(root)
        Rubinius.run_script(compiled_code)
      end

      # Return compiled code
      #
      # @return [Rubinius::CompiledCode]
      #
      # @api private
      #
      # FIXME: rbx on travis is older than on my devbox.
      #
      def compiled_code
        _script = script
        _script.respond_to?(:compiled_code) ? _script.compiled_code : _script.compiled_method
      end

      # Return code script
      #
      # @return [Rubinius::CompiledCode::Script]
      #
      # @api private
      #
      def script
        compiled_code_raw.create_script
      end

      # Return compiled code for node
      #
      # @return [Rubinius::CompiledCode]
      #
      # @api private
      #
      def compiled_code_raw
        compiler.run
      end

      # Return compiler loaded with mutated ast
      #
      # @return [Rubinius::Compiler]
      #
      # @api private
      #
      def compiler
        Rubinius::Compiler.new(:bytecode, :compiled_method).tap do |compiler|
          compiler.generator.input(@root)
        end
      end

      # Return script node
      #
      # @param [Rubinius::AST::Node] node
      #
      # @return [Rubinius::AST::Script]
      #
      # @api private
      #
      def script(node)
        Rubinius::AST::Script.new(node).tap do |script|
          script.file = source_path
        end
      end
    end
  end
end
