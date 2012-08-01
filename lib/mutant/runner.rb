module Mutant
  # Abstract runner for tests
  class Runner
    include Veritas::Immutable
    extend Abstract

    # Run runner
    #
    # @api private
    #
    # @return [Runner]
    #
    def self.run(*args)
      new(*args)
    end

    # Return subject of test
    #
    # @api private
    #
    # @return [Subject]
    #
    attr_reader :subject

    # Return mutant tested
    #
    # @api private
    #
    # @return [Rubnius::AST::Node]
    #
    attr_reader :mutant

    # Check if mutant was killed
    #
    # @return [true]
    #   returns true when mutant was killed
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    def killed?
      @killed
    end

  private

    private_class_method :new

    # Initialize runner and run the test
    #
    # @param [Subject] subject
    # @param [Rubinius::AST::Node] mutant
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(subject,mutant)
      @subject,@mutant = subject,mutant

      subject.insert(@mutant)
      @killed = run
      subject.reset
    end

    # Run test
    #
    # @return [true]
    #   returns true when mutant was killed
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    abstract :run
  end
end
