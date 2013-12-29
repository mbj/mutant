# encoding: utf-8

module Mutant
  # Base class for code loaders
  class Loader
    include AbstractType
    include Procto.call

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
    end

    # Eval based loader
    class Eval < self

      # Call loader
      #
      # @return [undefined]
      #
      # @api private
      #
      def call
        eval(
          source,
          TOPLEVEL_BINDING,
          @subject.source_path.to_s,
          @subject.source_line
        )
        nil
      end

    private

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
