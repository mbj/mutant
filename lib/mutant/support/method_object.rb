# encoding: utf-8

module Mutant
  # A mixing to create method object semantics
  module MethodObject

    # Hook called when descendant is extended
    #
    # @param [Module|Class] descendant
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.extended(descendant)
      descendant.class_eval do
        private_class_method :new
      end
    end

    # Run the method object
    #
    # Not aliased to prevent problems from inheritance
    #
    # @return [Objecct]
    #
    # @api private
    #
    def run(*args)
      new(*args)
    end

  end # MethodObject
end # Mutant
