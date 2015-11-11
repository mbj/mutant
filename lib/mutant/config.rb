module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
      :debug,
      :integration,
      :matcher,
      :includes,
      :requires,
      :reporter,
      :isolation,
      :fail_fast,
      :jobs,
      :zombie,
      :json_dump,
      :expected_coverage,
      :expression_parser
    )

    %i[fail_fast zombie debug].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

  end # Config
end # Mutant
