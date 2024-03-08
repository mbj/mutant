# frozen_string_literal: true

module Mutant
  class Test
    module Runner
      class Sink
        include Anima.new(:env)

        # Initialize object
        #
        # @return [undefined]
        def initialize(*)
          super
          @start        = env.world.timer.now
          @test_results = []
        end

        # Runner status
        #
        # @return [Result::Env]
        def status
          Result::TestEnv.new(
            env:          env,
            runtime:      env.world.timer.now - @start,
            test_results: @test_results
          )
        end

        # Test if scheduling stopped
        #
        # @return [Boolean]
        def stop?
          status.stop?
        end

        # Handle mutation finish
        #
        # @return [self]
        def response(response)
          if response.error
            env.world.stderr.puts(response.log)
            fail response.error
          end

          @test_results << response.result.with(output: response.log)
          self
        end
      end # Sink
    end # Runner
  end # Test
end # Mutant
