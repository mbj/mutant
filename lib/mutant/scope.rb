# frozen_string_literal: true

module Mutant
  # Class or Module bound to an exact expression
  class Scope
    include Anima.new(:raw, :expression)
  end # Scope
end # Mutant
