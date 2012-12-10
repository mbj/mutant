module Mutant
  # Generator for mutations
  class Mutator
    include Adamantium::Flat, AbstractType

    # Run mutator on input
    #
    # @param [Object] input
    # @param [#call] block
    #
    # @return [self]
    #
    # @api private
    #
    def self.each(node, &block)
      return to_enum(__method__, node) unless block_given?
      Registry.lookup(node.class).new(node, block)

      self
    end

    # Register node class handler
    #
    # @param [Class:Rubinius::AST::Node] node_class
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.handle(node_class)
      Registry.register(node_class,self)
    end
    private_class_method :handle

    # Return identity of object (for deduplication)
    #
    # @param [Object]
    #
    # @return [Object]
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

  private

    # Initialize object
    #
    # @param [Object] input
    # @param [#call(node)] block
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(input, block)
      @input, @block = IceNine.deep_freeze(input), block
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

    # Test if generated mutation is allowed
    #
    # @param [Object] object
    #
    # @return [true]
    #   if mutation is allowed
    #
    # @return [false]
    #   otherwise
    #
    def allow?(object)
      true
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
      return unless new?(object) and allow?(object)

      guard(object)

      emit!(object)
    end

    # Maximum amount of tries to generate a new object
    MAX_TRIES = 3

    # Call block until it generates a mutation
    #
    # The primary use of this method is to give the random generated object
    # a nice interface for retring generation when generation accidentally generated the
    # input
    #
    # @yield
    #   Execute block until object is generated where new?(object) returns true
    #
    # @return [self]
    #
    # @raise [RuntimeError]
    #   raises RuntimeError in case no new ast node can be generated after MAX_TRIES.
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
    # @param [Rubinius::AST::Node] node
    #
    # @return [self]
    #
    # @api private
    #
    def emit!(node)
      @block.call(node)
      self
    end

    # Shortcut to create a new unfrozen duplicate of input
    #
    # @return [Object]
    #
    # @api private
    #
    def dup_input
      Helper.deep_clone(input)
    end

  end
end
