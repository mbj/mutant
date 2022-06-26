# frozen_string_literal: true

module Mutant
  # Generator for mutations
  class Mutator
    include(
      Adamantium,
      Concord.new(:input, :parent),
      AbstractType,
      Procto
    )

    # Return output
    #
    # @return [Set<Parser::AST::Node>]
    attr_reader :output

    alias_method :call, :output

  private

    def initialize(_input, _parent = nil)
      super

      @output = Set.new

      dispatch
    end

    def new?(object)
      !object.eql?(input)
    end

    abstract_method :dispatch
    private :dispatch

    def emit(object)
      return unless new?(object)

      output << object
    end

    def run(mutator)
      mutator.call(input).each(&method(:emit))
    end

    def dup_input
      input.dup
    end

  end # Mutator
end # Mutant
