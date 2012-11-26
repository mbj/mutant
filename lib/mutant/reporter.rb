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
  end
end
