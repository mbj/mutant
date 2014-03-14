# encoding: utf-8

module Mutant
  # Base class for code loaders
  class Loader
    include AbstractType, Concord.new(:root, :subject), Procto.call

    # Eval based loader
    class Eval < self

      # Call loader
      #
      # @return [undefined]
      #
      # @api private
      #
      def call
        subject.prepare
        eval(
          source,
          TOPLEVEL_BINDING,
          subject.source_path.to_s,
          subject.source_line
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
        Unparser.unparse(root)
      end

    end # Eval

  end # Loader
end # Mutant
