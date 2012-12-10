module Mutant
  # Abstract reporter
  class Reporter
    include Adamantium::Flat, AbstractType

    # Report subject
    #
    # @param [Subject] subject
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :subject

    # Report mutation
    #
    # @param [Mutation] mutation
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :mutation

    # Report notice
    #
    # @param [String] notice
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :notice

    # Report killer
    #
    # @param [Killer] killer
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :killer

    # Report config
    # 
    # @param [Mutant::Config] config
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :config

    # Return output stream
    #
    # @return [IO]
    #
    # @api private
    #
    abstract_method :output_stream

    # Return error stream
    #
    # @return [IO]
    #
    # @api private
    #
    abstract_method :error_stream

  private

    # Initialize reporter
    #
    # @param [Config] config
    #
    # @api private
    #
    def initialize(config)
      @config = config
    end
  end
end
