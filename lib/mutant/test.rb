module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include AbstractType, Adamantium::Flat

    # Object to report test status
    class Report
      include Adamantium::Flat, Anima::Update, Anima.new(
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

      # Return marshallable data
      #
      # NOTE:
      #
      #  The test is intentionally NOT part of the mashalled data.
      #  In rspec the example group cannot deterministically being marshalled, because
      #  they reference a crazy mix of IO objects, global objects etc.
      #
      # @return [Array]
      #
      # @api private
      #
      def marshal_dump
        [@output, @success]
      end

      # Load marshalled data
      #
      # @param [Array] arry
      #
      # @return [undefined]
      #
      # @api private
      #
      def marshal_load(array)
        @output, @success = array
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
