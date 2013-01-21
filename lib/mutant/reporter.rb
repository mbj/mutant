module Mutant
  # Abstract reporter
  class Reporter
    include Adamantium::Flat, AbstractType, Equalizer.new(:stats)

    # Initialize reporter
    #
    # @param [Config] config
    #
    # @api private
    #
    def initialize(config)
      @stats = Stats.new
      @config = config
    end

    # Test for success
    #
    # @return [true]
    #   if there are subjects and no errors
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def success?
      stats.success?
    end

    # Report start
    #
    # @param [Config] config
    #
    # @return [self]
    #
    # @api private
    #
    def start(_config)
      self
    end

    # Report stop
    #
    # @return [self]
    #
    # @api private
    #
    def stop
      self
    end

    # Report subject
    #
    # @param [Subject] subject
    #
    # @return [self]
    #
    # @api private
    #
    def subject(subject)
      stats.count_subject
      self
    end

    # Report mutation
    #
    # @param [Mutation] mutation
    #
    # @return [self]
    #
    # @api private
    #
    def mutation(mutation)
      self
    end

    # Report killer
    #
    # @param [Killer] killer
    #
    # @return [self]
    #
    # @api private
    #
    def report_killer(killer)
      stats.count_killer(killer)

      self
    end

    # Test for running in debug mode
    #
    # @return [true]
    #   if running in debug mode
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def debug?
      config.debug?
    end

    # Return stats
    #
    # @return [Reporter::Stats]
    #
    # @api private
    #
    attr_reader :stats

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    attr_reader :config

    # Test if errors are present
    #
    # @return [true]
    #   if errors are present
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def errors?
      stats.errors?
    end

  end
end
