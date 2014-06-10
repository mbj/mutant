module Mutant
  # Generator for mutations
  class Mutator
    include Adamantium::Flat, AbstractType

    # Run mutator on input
    #
    # @param [Object] input
    #   the input to mutate
    #
    # @param [Mutator] parent
    #
    # @return [self]
    #
    # @api private
    #
    def self.each(input, parent = nil, &block)
      return to_enum(__method__, input, parent) unless block_given?
      Registry.lookup(input).new(input, parent, block)

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
      !@seen.include?(object)
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
      @seen << object
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
