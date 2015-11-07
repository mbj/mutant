module Mutant
  class Reporter
    class Hash
      class Printer
        # Printer for mutation config
        class Config < self

          # Report configuration
          #
          # @param [Mutant::Config] config
          #
          # @return [undefined]
          #
          # @api private
          def run
            matcher = object.matcher.inspect
            # #<Mutant::Matcher::Config match_expressions: [Rumble::Loop]>
            # Parse out expression [...]
            expression = matcher.scan(/\[([\w:,\*]+)\]/).flatten.first
            expression ||= matcher

            {
              matcher: expression,
              integration: object.integration,
              expect_coverage: (object.expected_coverage * 100).to_f,
              jobs: object.jobs,
              includes: object.includes,
              requires: object.requires
            }
          end

        end # Config
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
