module Mutant
  class Strategy 
    include AbstractType, Adamantium::Flat, Equalizer.new

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    attr_reader :config

    # Initialize object
    #
    # @param [Config] config
    #
    # @return [undefined
    #
    # @api private
    #
    def initialize(config)
      @config = config
    end

    # Return output stream
    #
    # @return [IO]
    #
    # @api private
    #
    def output_stream
      config.reporter.output_stream
    end

    # Return error stream
    #
    # @return [IO]
    #
    # @api private
    #
    def error_stream
      config.reporter.error_stream
    end

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Killer]
    #
    # @api private
    #
    def kill(mutation)
      killer.new(self, mutation)
    end

    # Return killer
    #
    # @return [Class:Killer]
    #
    # @api private
    #
    def killer
      self.class::KILLER
    end

    # Static strategies
    class Static < self
      include Equalizer.new

      # Always fail to kill strategy
      class Fail < self
        KILLER = Killer::Static::Fail
      end

      # Always succeed to kill strategy
      class Success < self
        KILLER = Killer::Static::Success
      end

    end
  end
end
