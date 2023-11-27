# frozen_string_literal: true

module Mutant
  class Loader
    include Anima.new(:binding, :kernel, :source, :subject)

    FROZEN_STRING_FORMAT = "# frozen_string_literal: true\n%s"
    VOID_VALUE_REGEXP    = /\A[^:]+:\d+: void value expression/

    private_constant(*constants(false))

    VOID_VALUE = Either::Left.new(nil)
    SUCCESS    = Either::Right.new(nil)

    # Call loader
    #
    # @return [Result]
    def self.call(*arguments)
      new(*arguments).call
    end

    # Call loader
    #
    # One off the very few valid uses of eval ever.
    #
    # @return [Result]
    #
    # rubocop:disable Metrics/MethodLength
    def call
      kernel.eval(
        FROZEN_STRING_FORMAT % source,
        binding,
        subject.source_path.to_s,
        subject.source_line
      )
    rescue SyntaxError => exception
      # rubocop:disable Style/GuardClause
      if VOID_VALUE_REGEXP.match?(exception.message)
        VOID_VALUE
      else
        raise
      end
    else
      SUCCESS
    end
  end # Loader
end # Mutant
