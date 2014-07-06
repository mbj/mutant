module Mutant
  # The configuration of a mutator run
  class Config
    include Adamantium, Anima::Update, Anima.new(
      :debug,
      :integration,
      :matcher_config,
      :includes,
      :requires,
      :reporter,
      :isolation,
      :fail_fast,
      :zombie,
      :expected_coverage
    )

    [:fail_fast, :zombie, :debug].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

  end # Config
end # Mutant
