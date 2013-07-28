# encoding: utf-8

module Mutant
  # Generator for mutations
  class Mutator
    include Adamantium::Flat, AbstractType

    # Run mutator on input
    #
    # @param [Parser::AST::Node] node
    # @param [#call] block
    #
    # @return [self]
    #
    # @api private
    #
    def self.each(node, parent = nil, &block)
      return to_enum(__method__, node, parent) unless block_given?
      Registry.lookup(node).new(node, parent, block)

      self
    end

    # Register node class handler
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.handle(*types)
      types.each do |type|
        Registry.register(type, self)
      end
    end
    private_class_method :handle

    # Return identity of object (for deduplication)
    #
    # @param [Object] object
    #
    # @return [Object]
    #
    # @api private
    #
    def self.identity(object)
      object
    end

    # Return input
    #
    # @return [Object]
    #
    # @api private
    #
    attr_reader :input

    # Return input
    #
    # @return [Object]
    #
    # @api private
    #
    attr_reader :parent

  private

    # Initialize object
    #
    # @param [Object] input
    # @param [Object] parent
    # @param [#call(node)] block
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(input, parent, block)
      @input, @parent, @block = input, parent, block
      @seen = Set.new
      guard(input)
      dispatch
    end

    # Test if generated object is not guarded from emmitting
    #
    # @param [Object] object
    #
    # @return [true]
    #   if generated object is different
    #
    # @return [false]
    #
    # @api private
    #
    def new?(object)
      !@seen.include?(self.class.identity(object))
    end

    # Add object to guarded values
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    #
    def guard(object)
      @seen << self.class.identity(object)
    end

    # Dispatch node generations
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :dispatch

    # Emit generated mutation if object is not equivalent to input
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit(object)
      return unless new?(object)

      guard(object)

      emit!(object)
    end

    # Maximum amount of tries to generate a new object
    MAX_TRIES = 3

    # Call block until it generates a mutation
    #
    # @yield
    #   Execute block until object is generated where new?(object) returns true
    #
    # @return [self]
    #
    # @raise [RuntimeError]
    #   raises RuntimeError when no new node can be generated after MAX_TRIES.
    #
    # @api private
    #
    def emit_new
      MAX_TRIES.times do
        object = yield

        if new?(object)
          emit!(object)
          return
        end
      end

      raise "New AST could not be generated after #{MAX_TRIES} attempts"
    end

    # Call block with node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [self]
    #
    # @api private
    #
    def emit!(node)
      @block.call(node)
      self
    end

    # Run input with mutator
    #
    # @return [undefined]
    #
    # @api private
    #
    def run(mutator)
      mutator.new(input, self, method(:emit))
    end

    # Shortcut to create a new unfrozen duplicate of input
    #
    # @return [Object]
    #
    # @api private
    #
    def dup_input
      input.dup
    end

  end # Mutator
end # Mutant
