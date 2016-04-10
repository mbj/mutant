module MutantSpec
  # Not a real VM, just kidding. It connects the require / eval triggers
  # require semantics Zombifier relies on in a way we can avoid having to
  # mock around everywhere to test every detail.
  class RubyVM
    include Concord::Public.new(:expected_events)

    # An event being observed by the VM handlers
    class EventObservation
      include Concord::Public.new(:type, :payload)
    end # EventObservation

    # An event being expected, can advance the VM
    class EventExpectation
      include AbstractType, Anima.new(
        :expected_payload,
        :trigger_requires,
        :return_value
      )

      DEFAULTS = IceNine.deep_freeze(trigger_requires: [])

      def initialize(attributes)
        super(DEFAULTS.merge(attributes))
      end

      def handle(vm, observation)
        unless match?(observation)
          fail "Unexpected event observation: #{observation.inspect}, expected #{inspect}"
        end

        trigger_requires.each(&vm.method(:require))

        self
      end

    private

      def match?(observation)
        observation.type.eql?(self.class) && observation.payload.eql?(expected_payload)
      end

      # Expectation and advance on require calls
      class Require < self
      end # Require

      # Expectation and advance on eval calls
      class Eval < self
      end # Eval
    end # EventExpectation

    # A fake implementation of Kernel#require
    def require(logical_name)
      handle_event(EventObservation.new(EventExpectation::Require, logical_name: logical_name))
    end

    # A fake implementation of Kernel#eval
    def eval(source, binding, location)
      handle_event(
        EventObservation.new(
          EventExpectation::Eval,
          binding:         binding,
          source:          source,
          source_location: location
        )
      )
    end

    # Test if VM events where fully processed
    def done?
      expected_events.empty?
    end

  private

    def handle_event(observation)
      fail "Unexpected event: #{observation.type} / #{observation.payload}" if expected_events.empty?

      expected_events.slice!(0).handle(self, observation).return_value
    end
  end # RubyVM
end # MutantSpec
