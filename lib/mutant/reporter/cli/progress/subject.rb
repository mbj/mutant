module Mutant
  class Reporter
    class CLI
      class Progress
        # CLI progress reporter for subjects
        class Subject < self

          handle Mutant::Subject

          # Run printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            puts("#{object.identification} mutations: #{object.mutations.length}")
            object.tests.each do |test|
              puts "- #{test.identification}"
            end
          end

        end # Subject
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
