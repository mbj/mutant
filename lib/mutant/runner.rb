module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Adamantium::Flat, AbstractType
    extend MethodObject

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
      run
    end

  private

    # Perform operation
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :run

  end
end
