module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      # Reporter subject
      #
      # @param [Subject] subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject(subject)
        @io.puts("Found subject: #{subject.identification}")
      end

      # Report mutations 
      #
      # @param [Mutation] mutations
      #
      # @return [self]
      #
      # @api private
      #
      def mutation(mutation)
        @io.puts("Mutation: #{mutation.identification}")
      end

      # Reporter killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def killer(killer)
        @io.puts('Killer: %s / %02.2fs' % [killer.identification,killer.runtime])

        if killer.fail?
          @io.puts "Uncovered mutation"
          @io.puts "=== Original ===\n#{killer.original_source}"
          @io.puts
          @io.puts "=== Mutation ===\n#{killer.mutation_source}"
        end
      end

    private 

      # Initialize reporter
      #
      # @param [IO] io
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(io)
        @io = io
      end
    end
  end
end
