module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include AbstractType, Adamantium::Flat

    # Object to report test status
    class Report
      include Anima.new(
        :test,
        :output,
        :success
      )

      alias_method :success?, :success

      # Test if test failed
      #
      # @return [Boolean]
      #
      # @api private
      #
      def failed?
        !success?
      end

    end # Report

    # Run tests
    #
    # @return [Test::Result]
    #
    # @api private
    #
    abstract_method :run

    # Return subject identification
    #
    # This method is used for current mutants primitive test selection.
    #
    # @return [String]
    #
    # @api private
    #
    abstract_method :subject_identification

  end # Test
end # Mutant
