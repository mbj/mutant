# frozen_string_literal: true

module Mutant
  # Generator for mutations
  class Mutator

    REGISTRY = Registry.new

    include Adamantium::Flat, Concord.new(:input, :parent), AbstractType, Procto.call(:output)

    # Lookup and invoke dedicated AST mutator
    #
    # @param node [Parser::AST::Node]
    # @param parent [nil,Mutant::Mutator::Node]
    #
    # @return [Set<Parser::AST::Node>]
    def self.mutate(node, parent = nil)
      self::REGISTRY.lookup(node.type).call(node, parent)
    end

    def self.handle(*types)
      types.each do |type|
        self::REGISTRY.register(type, self)
      end
    end
    private_class_method :handle

    # Return output
    #
    # @return [Set<Parser::AST::Node>]
    attr_reader :output

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
