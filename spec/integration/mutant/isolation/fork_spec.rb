# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Fork, mutant: false do
  # rubocop:disable Lint/AmbiguousBlockAssociation
  specify do
    a = 1
    expect do
      Mutant::Config::DEFAULT.isolation.call { a = 2 }
    end.to_not change { a }
  end
end
