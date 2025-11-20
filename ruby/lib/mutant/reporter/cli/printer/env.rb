# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Env printer
        class Env < self
          delegate(
            :amount_available_tests,
            :amount_mutations,
            :amount_selected_tests,
            :amount_subjects,
            :amount_all_tests,
            :config,
            :test_subject_ratio
          )

          FORMATS = [
            [:info,   'Subjects:        %s',        :amount_subjects       ],
            [:info,   'All-Tests:       %s',        :amount_all_tests      ],
            [:info,   'Available-Tests: %s',        :amount_available_tests],
            [:info,   'Selected-Tests:  %s',        :amount_selected_tests ],
            [:info,   'Tests/Subject:   %0.2f avg', :test_subject_ratio    ],
            [:info,   'Mutations:       %s',        :amount_mutations      ]
          ].each(&:freeze)

          # Run printer
          #
          # @return [undefined]
          def run
            info('Mutant environment:')
            visit(Config, config)
            FORMATS.each do |report, format, value|
              __send__(report, format, __send__(value))
            end
          end
        end # Env
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
