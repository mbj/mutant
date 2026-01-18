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
      :pathname,
      :process,
      :random,
      :recorder,
      :stderr,
      :stdout,
      :tempfile,
      :thread,
      :time,
      :timer
    )

    INSPECT = '#<Mutant::World>'

    private_constant(*constants(false))

    # Object inspection
    #
    # @return [String]
    def inspect = INSPECT

    class CommandStatus
      include Adamantium, Anima.new(:process_status, :stderr, :stdout)
    end # CommandStatus

    # Capture stdout of a command
    #
    # @param [Array<String>] command
    #
    # @return [Either<CommandStatus,CommandStatus>]
    def capture_command(command)
      stdout, stderr, process_status = open3.capture3(*command, binmode: true)

      (process_status.success? ? Either::Right : Either::Left).new(
        CommandStatus.new(
          process_status:,
          stderr:,
          stdout:
        )
      )
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
          allowed_time:,
          timer:
        )
      else
        Timer::Deadline::None.new
      end
    end

    def record(name, &)
      recorder.record(name, &)
    end

    def process_warmup
      process.warmup if process.respond_to?(:warmup)
    end
  end # World
end # Mutant
