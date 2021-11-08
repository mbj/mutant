# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Subject < self
          NAME              = 'subject'
          SHORT_DESCRIPTION = 'Subject subcommands'

        private

          def print_subject_amount(env)
            print('Subjects in environment: %d' % env.subjects.length)
          end

          def print(message)
            world.stdout.puts(message)
          end

          class Selections < self
            NAME              = 'selections'
            SHORT_DESCRIPTION = 'List subjects test selections'
            SUBCOMMANDS       = []

            def action
              bootstrap.fmap(&method(:list_subject_selections))
            end

            def list_subject_selections(env)
              print_subject_amount(env)

              env.subjects.each do |subject|
                print_subject_selections(env, subject)
              end
            end

            def print_subject_selections(env, subject)
              selection = env.selections.fetch(subject)

              print("#{subject.expression.syntax}: #{selection.length}")

              selection.each do |test|
                print("* #{test.identification}")
              end
            end
          end

          class List < self
            NAME              = 'list'
            SHORT_DESCRIPTION = 'List subjects'
            SUBCOMMANDS       = EMPTY_ARRAY

          private

            def action
              bootstrap.fmap(&method(:list_subjects))
            end

            def list_subjects(env)
              print_subject_amount(env)

              env.subjects.each do |subject|
                print(subject.expression.syntax)
              end
            end
          end

          SUBCOMMANDS = [List, Selections].freeze
        end # Subject
      end # Environment
    end # Command
  end # CLI
end # Mutant
