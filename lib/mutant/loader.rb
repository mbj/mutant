module Mutant
  # Base class for code loaders
  class Loader
    include AbstractType
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
    # @param [String] file
    # @param [Fixnum] line
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(root, file, line)
      @root, @file, @line = root, file, line
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
        eval(source, TOPLEVEL_BINDING, @file, @line)
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

  end
end
