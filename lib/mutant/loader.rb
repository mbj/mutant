# frozen_string_literal: true

module Mutant
  class Loader
    include Anima.new(:binding, :kernel, :source, :subject)

    FROZEN_STRING_FORMAT = "# frozen_string_literal: true\n%s"
    VOID_VALUE_REGEXP    = /\A[^:]+:\d+: void value expression/.freeze

    private_constant(*constants(false))

    class Result
      include Singleton

      # Vale returned on successful load
      class Success < self
      end # Success

      # Vale returned on MRI detecting void value expressions
      class VoidValue < self
      end # VoidValue
    end # Result

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
        Result::VoidValue.instance
      else
        raise
      end
    else
      Result::Success.instance
    end
  end # Loader
end # Mutant
