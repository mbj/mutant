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
    private_class_method :new

    # Load an AST into the rubinius VM
    #
    # @param [Rubinius::AST::Script] root
    #   A root AST node to be loaded into the VM
    #
    # @return [self]
    #
    # @api private
    #
    def self.load(root)
      new(root)

      self
    end

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
      @root = root
      root.file ||= '(mutant)'
      Rubinius.run_script(compiled_code)
    end

    # Return compiled code for node
    #
    # This method actually returns a Rubnius::CompiledMethod
    # instance. But it is named on the future name of CompiledMethod
    # that will be renamed to Rubinius::CompiledCode.
    #
    # @return [Rubinius::CompiledMethod]
    #
    # @api private
    #
    def compiled_code
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
