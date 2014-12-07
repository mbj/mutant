module Mutant
  # Abstract test selector for mutation subjects
  class Selector
    include AbstractType, SimpleInspect

    # Return tests for subject
    #
    # @param [Subject] subject
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    #
    abstract_method :call

    # Return precomputed selectors
    #
    # @param [Enumerable<Subject>] subjects
    #
    # @return [Static]
    #
    # @api private
    #
    def precompute(subjects)
      Static.new(subjects.each_with_object({}) do |subject, map|
        map[subject] = call(subject)
      end)
    end

  private

    # Return all tests
    #
    # @return [Enumerable<Test>]
    #
    def all_tests
      integration.all_tests
    end

    # Selector that blindly selects all specs
    class All < self
      include Concord.new(:config)

      # Return tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def call(_subject)
        integration.all_tests
      end
    end # All

    # Selector that blindly selects no specs
    class Null < self

      # Return tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def call(_subject)
        EMPTY_ARRAY
      end
    end # Null

    # Selector that intersects multiple selectors
    class Intersection < self
      include Concord.new(:integration, :selectors)

      # Return tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def call(subject)
        selectors.reduce(integration.all_tests.to_set) do |remaining, selector|
          remaining & selector.call(subject)
        end
      end

    end # Intersect

    # Selector that selects tests based on trace results
    class Trace < self
      include Concord.new(:trace)

      # Return tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def call(subject)
        lines = trace.fetch(subject.source_path, {})
        subject.source_lines.reduce(EMPTY_SET) do |tests, line|
          tests | lines.fetch(line, EMPTY_SET)
        end
      end
    end # Trace

    # Static
    class Static < self
      include Concord.new(:map)

      # Return tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def call(subject)
        map.fetch(subject)
      end

    end # Static
  end # Selector
end # Mutant
