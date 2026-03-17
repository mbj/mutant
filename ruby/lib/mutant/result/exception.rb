# frozen_string_literal: true

module Mutant
  module Result
    # Serializable exception data
    class Exception
      include Anima.new(
        :backtrace,
        :message,
        :original_class
      )

      # Build from a Ruby exception
      #
      # @param [::Exception] exception
      #
      # @return [Exception]
      def self.from_exception(exception)
        new(
          backtrace:      exception.backtrace,
          message:        exception.message,
          original_class: exception.class.name
        )
      end

      JSON = Transform::JSON.for_anima(self)
    end # Exception
  end # Result
end # Mutant
