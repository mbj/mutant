# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include Anima.new(
        :exception,
        :log,
        :process_status,
        :timeout,
        :value
      )

      # Test for successful result
      #
      # @return [Boolean]
      def valid_value?
        timeout.nil? && exception.nil? && (process_status.nil? || process_status.success?)
      end

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'exception'      => object.exception&.to_h&.transform_keys(&:to_s),
            'log'            => object.log,
            'process_status' => object.process_status&.to_h&.transform_keys(&:to_s),
            'timeout'        => object.timeout,
            'value'          => object.value&.to_h&.transform_keys(&:to_s)
          }
        end
      )

      load = Transform::Success.new(
        block: lambda do |hash|
          new(
            exception:      hash['exception'] && Mutant::Result::Exception.new(**hash['exception'].transform_keys(&:to_sym)),
            log:            hash['log'],
            process_status: hash['process_status'] && Mutant::Result::ProcessStatus.new(**hash['process_status'].transform_keys(&:to_sym)),
            timeout:        hash['timeout'],
            value:          hash['value'] && Mutant::Result::Test.new(**hash['value'].transform_keys(&:to_sym))
          )
        end
      )

      JSON = Transform::JSON.new(dump_transform: dump, load_transform: load)
    end # Result

    # Call block in isolation
    #
    # @return [Result]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
