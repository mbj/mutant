module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
      :debug,
      :expected_coverage,
      :fail_fast,
      :includes,
      :integration,
      :jobs,
      :matcher,
      :requires,
      :reporter,
      :zombie
    )

    %i[fail_fast zombie debug].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

  end # Config
end # Mutant
