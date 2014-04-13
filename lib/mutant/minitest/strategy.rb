# encoding: utf-8

module Mutant
  module Minitest
    # Rspec killer strategy
    class Strategy < Mutant::Strategy

      register 'minitest'

      KILLER = Killer::Forking.new(Minitest::Killer)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        Minitest.set_active
        Pathname.glob(Pathname.new('.').join('test/**/*_test.rb')) do |path|
          require "./#{path}"
        end
        self
      end
      memoize :setup

      # Return tests provider
      #
      # @return [#call(subject)]
      #
      # @api private
      #
      def test_provider
        if ::Minitest.respond_to?(:mutant_killers)
          ::Minitest.method(:mutant_killers)
        else
          self.class.method(:all_tests)
        end
      end
      memoize :test_provider

      # Return all tests from minitest
      #
      # @return [Enumerable<Minitest::Unit::TestCase>]
      #
      # @api private
      #
      def self.all_tests(_subject)
        @all_tests ||= ::MiniTest::Unit::TestCase.test_suites.each_with_object([]) do |suite, tests|
          suite.test_methods.each do |method|
            tests << suite.new(method)
          end
        end
      end
      private_class_method :all_tests

    end # Strategy
  end # Rspec
end # Mutant
