module Mutant
  class Runner
    class Reporter
      def self.run(*args)
        new(*args)
      end

    private

      def initialize(output, runner)
        @output, @runner = output, runner
        run
      end

      def run
        @runner.errors.each do |error|
          print_error(error)
        end
      end

      def print_error(error)
        Kill.run(output, error)
      end
    end

    class Reporter
      class Kill
        def self.run(*args)
          new(*args)
        end

      private 

        def initialize(output, error)
          @output, @error = output, error
          run
        end

        def mutant
          @error.mutant
        end

        def root_ast
        end
      end
    end
  end
end

module Mutant
  class Runner
    include Immutable

    def self.run(options)
      killer = options.fetch(:killer) do
        raise ArgumentError, 'Missing :killer in options'
      end

      pattern = options.fetch(:pattern) do
        raise ArgumentError, 'Missing :pattern in options'
      end

      new(killer, pattern)
    end

    attr_reader :errors

    def errors?
      errors.empty?
    end


  private

    def initialize(killer, pattern)
      @killer, @pattern, @errors = killer, pattern, []
      run
    end

    def matcher_classes
      [Matcher::Method::Singleton, Matcher::Method::Instance]
    end

    def constants
      ObjectSpace.each_object(Module).select do |constant|
        @pattern =~ constant.name
      end
    end

    def matchers
      matcher_classes.each_with_object([]) do |klass, matchers|
        matchers.concat(matches_for(klass))
      end
    end

    def matches_for(klass)
      constants.each_with_object([]) do |constant, matches|
        matches.concat(klass.extract(constant))
      end
    end

    def subjects
      matchers.each_with_object([]) do |matcher, subjects|
        subjects.concat(matcher.each.to_a)
      end
    end

    def killers
      subjects.each_with_object([]) do |subject, killers|
        killers.concat(killers_for(subject))
      end
    end

    def killers_for(subject)
      subject.map do |mutation|
        @killer.run(subject, mutation)
      end
    end

    def run
      killers.select do |killer|
        killer.fail?
      end.each do |killer|
        errors << killer
      end
    end
  end
end
