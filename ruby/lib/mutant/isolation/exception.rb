# frozen_string_literal: true

module Mutant
  # Module providing isolation
  class Isolation
    # Generic serializable exception data.
    #
    # This is required as our honored guests the Rails* ecosystem
    # makes Marshal.dump on exceptions impossible.
    #
    # @see https://twitter.com/_m_b_j_/status/1356433184850907137
    #
    # for the full story and eventual reactions.
    class Exception
      include Anima.new(
        :backtrace,
        :message,
        :original_class
      )
    end # Exception
  end # Isolation
end # Mutant
