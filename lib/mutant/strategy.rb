module Mutant
  class Strategy 
    include AbstractType

    # Kill mutation
    #
    # @param [Mutation]
    #
    # @return [Killer]
    #
    # @api private
    #
    def self.kill(mutation)
      killer.new(self, mutation)
    end

    def self.killer
      self::KILLER
    end

    class Static < self
      class Fail < self
        KILLER = Killer::Static::Fail
      end

      class Success < self
        KILLER = Killer::Static::Success
      end
    end

    class Rspec < self

      def self.original_world
        @original_world ||=
          begin
            require './spec/spec_helper'
            ::RSpec.world
          end
      end

      def self.prepare_world
        ::RSpec.instance_variable_set(:@world, original_world)
        ::RSpec.reset
        cleanup_world
      end

      def self.cleanup_world
        ::RSpec::Core::ExampleGroup.children.clear
        ::RSpec::Core::ExampleGroup.constants.each do |name|
          if name =~ /^Nested/
            RSpec::Core::ExampleGroup.send(:remove_const, name)
          end
        end
      end

      KILLER = Killer::Rspec

      class DM2 < self

        def self.filename_pattern(mutation)
          name = mutation.subject.context.scope.name

          append = mutation.subject.matcher.kind_of?(Matcher::Method::Singleton) ? '/class_methods' : ''

          path = Inflector.underscore(name)

          "spec/unit/#{path}#{append}/*_spec.rb"
        end

      end

      class Unit < self
        def self.filename_pattern(mutation)
          'spec/unit/**/*_spec.rb'
        end
      end

      class Full < self
        def self.filename_pattern(mutation)
          'spec/**/*_spec.rb'
        end
      end
    end
  end
end
