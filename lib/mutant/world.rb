# frozen_string_literal: true

module Mutant
  # The outer world IO objects mutant does interact with
  class World
    include Adamantium::Flat, Anima.new(
      :condition_variable,
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
      :stderr,
      :stdout,
      :thread,
      :timer,
      :warnings
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
  end # World
end # Mutant
