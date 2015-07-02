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
      # One off the very few valid uses of eval
      #
      # rubocop:disable Lint/Eval
      #
      # @api private
      def call
        eval(
          source,
          TOPLEVEL_BINDING,
          subject.source_path.to_s,
          subject.source_line
        )
        self
      end

    private

      # Return source
      #
      # @return [String]
      #
      # @api private
      def source
        Unparser.unparse(root)
      end

    end # Eval

  end # Loader
end # Mutant
