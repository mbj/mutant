# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Subject < self
          NAME              = 'subject'
          SHORT_DESCRIPTION = 'Subject subcommands'

          class List < self
            NAME              = 'list'
            SHORT_DESCRIPTION = 'List subjects'
            SUBCOMMANDS       = EMPTY_ARRAY

          private

            def action
              bootstrap.fmap(&method(:list_subjects))
            end

            def list_subjects(env)
              print('Subjects in environment: %d' % env.subjects.length)
              env.subjects.each do |subject|
                print(subject.expression.syntax)
              end
            end
          end

          SUBCOMMANDS = [List].freeze
        end # Subject
      end # Environment
    end # Command
  end # CLI
end # Mutant
