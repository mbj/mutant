module Mutant
  # The configuration of a mutator run
  class Config
    include Adamantium::Flat, Anima::Update, Anima.new(
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
      :expected_coverage,
      :expression_parser
    )

    %i[fail_fast zombie debug].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

  end # Config
end # Mutant
