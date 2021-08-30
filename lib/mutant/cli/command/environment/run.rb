# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Run < self
          NAME              = 'run'
          SHORT_DESCRIPTION = 'Run code analysis'
          SLEEP             = 60
          SUBCOMMANDS       = EMPTY_ARRAY

          UNLICENSED = <<~MESSAGE.lines.freeze
            Soft fail, continuing in #{SLEEP} seconds
            Next major version will enforce the license
            See https://github.com/mbj/mutant#licensing
          MESSAGE

          # Test if command needs to be executed in zombie environment
          #
          # @return [Bool]
          def zombie?
            @config.zombie
          end

        private

          def action
            soft_fail(License.call(world))
              .bind { bootstrap }
              .bind(&Runner.public_method(:call))
              .bind(&method(:from_result))
          end

          def from_result(result)
            if result.success?
              Either::Right.new(nil)
            else
              Either::Left.new('Uncovered mutations detected, exiting nonzero!')
            end
          end

          def soft_fail(result)
            result.either(
              lambda do |message|
                stderr = world.stderr
                stderr.puts(message)
                UNLICENSED.each { |line| stderr.puts(unlicensed(line)) }
                world.kernel.sleep(SLEEP)
                Either::Right.new(nil)
              end,
              ->(_subscription) { Either::Right.new(nil) }
            )
          end

          def unlicensed(message)
            "[Mutant-License-Error]: #{message}"
          end
        end # Run
      end # Environment
    end # Command
  end # CLI
end # Mutant
