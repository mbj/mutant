# frozen_string_literal: true

require 'minitest'

module Mutant
  module Minitest
    module Coverage
      # Setup coverage declaration for current class
      #
      # @param [String]
      #
      # @example
      #
      #   class MyTest < MiniTest::Test
      #     cover 'MyCode*'
      #
      #     def test_some_stuff
      #     end
      #   end
      #
      # @api public
      def cover(expression)
        if defined?(@cover_expression)
          fail "#{self} already declares to cover: #{@cover_expression.inspect}"
        end

        @cover_expression = expression
      end

      # Effective coverage expression
      #
      # @return [String, nil]
      #
      # @api private
      def resolve_cover_expression
        return @cover_expression if defined?(@cover_expression)

        try_superclass_cover_expression
      end

    private

      def try_superclass_cover_expression
        return if superclass.equal?(::Minitest::Runnable)

        superclass.resolve_cover_expression
      end

    end # Coverage
  end # Minitest
end # Mutant

Minitest::Test.extend(Mutant::Minitest::Coverage)
