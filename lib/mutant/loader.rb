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
    # @param [Parser::AST::Node] root
    # @param [Subject] subject
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(root, subject)
      @root, @subject = root, subject
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
        eval(
          source,
          TOPLEVEL_BINDING,
          @subject.source_path.to_s,
          @subject.source_line
        )
      end

      # Return source
      #
      # @return [String]
      #
      # @api private
      #
      def source
        Unparser.unparse(@root)
      end
    end # Eval

  end # Loader
end # Mutant
