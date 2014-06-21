module Mutant
  # Runner baseclass
  class Runner
    include Adamantium::Flat, AbstractType

    REGISTRY = {}

    # Register handler
    #
    # @param [Class] klass
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.register(klass)
      REGISTRY[klass] = self
    end
    private_class_method :register

    # Lookup runner
    #
    # @param [Class] klass
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.lookup(klass)
      current = klass
      while current
        return REGISTRY.fetch(current) if REGISTRY.key?(current)
        current = current.superclass
      end

      raise ArgumentError, "No handler for: #{klass}"
    end
    private_class_method :lookup

    # Run runner for object
    #
    # @param [Config] config
    # @param [Object] object
    #
    # @return [Runner]
    #
    # @api private
    #
    def self.run(config, object, *arguments)
      handler = lookup(object.class)
      handler.new(config, object, *arguments)
    end

    # Test if runner is running
    #
    # Yeah this is evil. Should be refactored away
    #
    # @return [Boolean]
    #
    def running?
      @running
    end

    # Return config
    #
    # @return [Mutant::Config]
    #
    # @api private
    #
    attr_reader :config

    # Initialize object
    #
    # @param [Config] config
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(config)
      @config = config
      @stop   = false
      @start  = Time.now
      @running = true
      progress(self)
      run
      @running = false
      progress(self)
      @end = Time.now
    end

    # Test if runner should stop
    #
    # @return [Boolean]
    #
    # @api private
    #
    def stop?
      @stop
    end

    # Return runtime
    #
    # @return [Float]
    #
    # @api private
    #
    def runtime
      (@end || Time.now) - @start
    end

    # Test if runner is successful
    #
    # @return [Boolean]
    #
    # @api private
    #
    abstract_method :success?

  private

    # Perform operation
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :run

    # Run reporter on object
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    #
    def progress(object)
      reporter.progress(object)
    end

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    def reporter
      config.reporter
    end

    # Perform dispatch on multiple inputs
    #
    # @param [Enumerable<Object>] input
    #
    # @return [Enumerable<Runner>]
    #
    # @api private
    #
    def visit_collection(input, *arguments)
      collection = []
      input.each do |object|
        runner = visit(object, *arguments)
        collection << runner
        @stop = runner.stop?
        break if @stop
      end
      collection
    end

    # Visit object
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit(object, *arguments)
      Runner.run(config, object, *arguments)
    end

  end # Runner
end # Mutant
