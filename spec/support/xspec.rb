# frozen_string_literal: true

module XSpec
  class MessageReaction
    include Concord.new(:event_list)

    TERMINATE_EVENTS = IceNine.deep_freeze(%i[return exception].to_set)
    VALID_EVENTS     = IceNine.deep_freeze(%i[return exception yields].to_set)

    private_constant(*constants(false))

    def call(observation)
      event_list.map do |event, object|
        __send__(event, observation, object)
      end.last
    end

    # Parse events into reaction
    #
    # @param [Array{Symbol,Object}, Hash{Symbol,Object}]
    #
    # @return [MessageReaction]
    def self.parse(events)
      event_list = events.to_a
      assert_valid(event_list)
      new(event_list)
    end

  private

    def return(_event, value)
      value
    end

    def exception(_event, exception)
      fail exception
    end

    def yields(observation, yields)
      block = observation.block or fail 'No block passed where expected'

      validate_block_arity(observation, yields)

      block.call(*yields)
    end

    def validate_block_arity(observation, yields)
      expected, observed = yields.length, observation.block.arity

      # block allows anything we can skip the check
      return if observed.equal?(-1)
      fail 'Optargs currently not supported' if observed < -1
      block_arity_mismatch(observation, expected, observed) unless expected.equal?(observed)
    end

    def block_arity_mismatch(observation, expected, observed)
      fail "block arity mismatch, expected #{expected} observed #{observed}\nobservation:\n#{observation.inspect}"
    end

    alias_method :yields_return, :yields

    def self.assert_valid(event_list)
      assert_not_empty(event_list)
      assert_valid_events(event_list)
      assert_total(event_list)
    end
    private_class_method :assert_valid

    def self.assert_valid_events(event_list)
      event_list.map(&:first).each do |event|
        fail "Invalid event: #{event}" unless VALID_EVENTS.include?(event)
      end
    end
    private_class_method :assert_valid_events

    def self.assert_not_empty(event_list)
      fail 'no events' if event_list.empty?
    end
    private_class_method :assert_not_empty

    def self.assert_total(event_list)
      return unless event_list[0..-2].map(&:first).any?(&TERMINATE_EVENTS.method(:include?))

      fail "Reaction not total: #{event_list}"
    end
    private_class_method :assert_total
  end # MessageReaction

  class MessageExpectation
    include Anima.new(:receiver, :selector, :arguments, :reaction)

    # rubocop:disable ParameterLists
    def self.parse(receiver:, selector:, arguments: [], reaction: nil)
      new(
        receiver:  receiver,
        selector:  selector,
        arguments: arguments,
        reaction:  MessageReaction.parse(reaction || { return: nil })
      )
    end

    def call(observation)
      Verifier.new(self, observation).call
    end

    class Verifier
      include Concord.new(:expectation, :observation)

      VERIFIED_ATTRIBUTES = IceNine.deep_freeze(%i[receiver selector arguments])

      def call
        VERIFIED_ATTRIBUTES.each(&method(:assert_expected_attribute))

        expectation.reaction.call(observation)
      end

    private

      def assert_expected_attribute(name)
        error("#{name} mismatch") unless observation.public_send(name).eql?(expectation.public_send(name))
      end

      def error(message)
        fail "#{message},\n observation:\n #{observation.inspect}\n expectation:\n #{expectation.inspect}"
      end

      def trigger_exception
        exception = expectation.exception
        fail exception if exception
      end

    end # Verifier
  end # MessageExpectation

  class MessageObservation
    include Anima.new(:receiver, :selector, :arguments, :block)
  end # MessageObservation

  class ExpectationVerifier
    include Concord.new(:expectations)

    def call(observation)
      expectation = expectations.shift or fail "No expected message but observed #{observation}"
      expectation.call(observation)
    end

    def assert_done
      expectations.empty? or fail "unconsumed expectations:\n#{expectations.map(&:inspect).join}"
    end

    # rubocop:disable MethodLength
    def self.verify(rspec_context, expectations)
      verifier = new(expectations)

      hooks = expectations
        .map { |expectation| [expectation.receiver, expectation.selector] }
        .to_set

      hooks.each do |receiver, selector|
        rspec_context.instance_eval do
          allow(receiver).to receive(selector) do |*arguments, &block|
            verifier.call(
              MessageObservation.new(
                receiver:  receiver,
                selector:  selector,
                arguments: arguments,
                block:     block
              )
            )
          end
        end
      end

      yield

      verifier.assert_done
    end
  end # ExpectationVerifier
end # XSpec
