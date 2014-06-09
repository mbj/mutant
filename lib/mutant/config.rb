module Mutant
  # The configuration of a mutator run
  class Config
    include Adamantium::Flat, Anima.new(
      :cache,
      :debug,
      :strategy,
      :matcher,
      :reporter,
      :fail_fast,
      :zombie,
      :expected_coverage
    )

    # Enumerate subjects
    #
    # @api private
    #
    # @return [self]
    #   if block given
    #
    # @return [Enumerator<Subject>]
    #   otherwise
    #
    # @api private
    #
    def subjects(&block)
      return to_enum(__method__) unless block_given?
      matcher.each(&block)
      self
    end

  end # Config
end # Mutant
