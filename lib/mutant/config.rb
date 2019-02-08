# frozen_string_literal: true

module Mutant
  # The outer world IO objects mutant does interact with
  class World
    include Adamantium::Flat, Anima.new(
      :condition_variable,
      :io,
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
      :thread
    )
  end # World

  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
      :expression_parser,
      :fail_fast,
      :includes,
      :integration,
      :isolation,
      :jobs,
      :matcher,
      :reporter,
      :requires,
      :zombie
    )

    %i[fail_fast zombie].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

  end # Config
end # Mutant
