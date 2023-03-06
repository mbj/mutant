# frozen_string_literal: true

module Mutant
  # The outer world IO objects mutant does interact with
  class World
    include Adamantium, Anima.new(
      :condition_variable,
      :environment_variables,
      :gem,
      :gem_method,
      :io,
      :json,
      :kernel,
      :load_path,
      :marshal,
      :mutex,
      :object_space,
      :open3,
      :parser,
      :pathname,
      :process,
      :random,
      :recorder,
      :stderr,
      :stdout,
      :thread,
      :timer
    )

    INSPECT = '#<Mutant::World>'

    private_constant(*constants(false))

    # Object inspection
    #
    # @return [String]
    def inspect
      INSPECT
    end

    # Capture stdout of a command
    #
    # @param [Array<String>] command
    #
    # @return [Either<String,String>]
    def capture_stdout(command)
      stdout, status = open3.capture2(*command, binmode: true)

      if status.success?
        Either::Right.new(stdout)
      else
        Either::Left.new("Command #{command} failed!")
      end
    end

    # Try const get
    #
    # @param [String]
    #
    # @return [Class|Module|nil]
    #
    # rubocop:disable Lint/SuppressedException
    def try_const_get(name)
      kernel.const_get(name)
    rescue NameError
    end
    # rubocop:enable Lint/SuppressedException

    # Deadline
    #
    # @param [Float, nil] allowed_time
    def deadline(allowed_time)
      if allowed_time
        Timer::Deadline.new(
          allowed_time: allowed_time,
          timer:        timer
        )
      else
        Timer::Deadline::None.new
      end
    end

    def record(name, &block)
      recorder.record(name, &block)
    end
  end # World
end # Mutant
