require 'mutant/actor'

# A fake actor used from specs
module FakeActor
  class Expectation
    include Concord::Public.new(:name, :message)
  end

  class MessageSequence
    include Adamantium::Flat, Concord.new(:messages)

    def self.new
      super([])
    end

    def add(name, *message_arguments)
      messages << Expectation.new(name, Mutant::Actor::Message.new(*message_arguments))
      self
    end

    def sending(expectation)
      raise "Unexpected send: #{expectation.inspect}" if messages.empty?
      expected = messages.shift
      unless expectation.eql?(expected)
        raise "Got:\n#{expectation.inspect}\nExpected:\n#{expected.inspect}"
      end
      self
    end

    def receiving(name)
      raise "No message to read for #{name.inspect}" if messages.empty?
      expected = messages.shift
      raise "Unexpected message #{expected.inspect} for #{name.inspect}" unless expected.name.eql?(name)
      expected.message
    end

    def consumed?
      messages.empty?
    end
  end

  class Env
    include Concord.new(:messages, :mailbox_names)

    def spawn
      mailbox = mailbox(next_name)
      yield mailbox if block_given?
      mailbox.sender
    end

    def mailbox(name)
      Mailbox.new(name, @messages)
    end

    def new_mailbox
      mailbox(:current)
    end

  private

    def next_name
      @mailbox_names.shift.tap do |name|
        name or fail 'Tried to spawn actor when no name available'
      end
    end
  end # Env

  class Mailbox
    include Concord.new(:name, :messages)

    def receiver
      Receiver.new(name, messages)
    end

    def sender
      Sender.new(name, messages)
    end

    def bind(sender)
      Mutant::Actor::Binding.new(self, sender)
    end
  end

  class Sender
    include Concord.new(:name, :messages)

    def call(message)
      messages.sending(Expectation.new(name, message))
    end
  end # Sender

  class Receiver
    include Concord::Public.new(:name, :messages)

    def call
      messages.receiving(name)
    end
  end
end
