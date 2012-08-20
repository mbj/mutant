module Mutant
  # A method object for inserting an AST into the Rubinius VM
  #
  # The idea is to split the steps for a mutation into documented
  # methods. Also subclasses can override the steps. Also passing
  # around the root node is not needed with a method object.
  #
  # As the initializer does the work there is no need for the
  # instances of this class to be used outside of this class, hence
  # the Loader.new method is private and the Loader.run method
  # returns self.
  #
  class Loader
    extend MethodObject

  private

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
  end
end
