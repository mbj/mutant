module Mutant
  class Strategy
    class Rspec
      class DM2

        # Example lookup for the rspec dm2 
        class Lookup
          include AbstractType, Adamantium::Flat, Equalizer.new(:subject)

          # Return subject
          #
          # @return [Subject]
          #
          # @api private
          #
          attr_reader :subject

          # Return glob expression
          #
          # @return [String]
          #
          # @api private
          #
          abstract_method :spec_files

          # Initalize object
          #
          # @param [Mutation] mutation
          #
          # @api private
          #
          def initialize(subject)
            @subject = subject
          end

          # Perform example lookup
          #
          # @param [Subject] subject
          #
          # @return [Enumerable<String>]
          #
          # @api private
          #
          def self.run(subject)
            build(subject).spec_files
          end

          REGISTRY = {}

          # Register subject hander
          #
          # @param [Class:Subject]
          #
          # @return [undefined]
          #
          # @api private
          #
          def self.handle(subject_class)
            REGISTRY[subject_class]=self
          end
          private_class_method :handle

          # Build lookup object
          #
          # @param [Subjecŧ] subject
          #
          # @return [Lookup] 
          #
          # @api private
          #
          def self.build(subject)
            REGISTRY.fetch(subject.class).new(subject)
          end

        end
      end
    end
  end
end
