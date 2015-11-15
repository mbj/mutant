module Mutant
  module Actor
    # Actor root environment
    class Env
      include Concord.new(:thread_root)

      # Spawn a new actor executing block
      #
      # @return [Actor::Sender]
      def spawn
        mailbox = new_mailbox

        thread_root.new do
          yield mailbox
        end

        mailbox.sender
      end

      # New unbound mailbox
      #
      # @return [Mailbox]
      def new_mailbox
        Mailbox.new
      end

    end # Env
  end # Actor
end # Mutant
