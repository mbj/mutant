# frozen_string_literal: true

RSpec.describe 'Mutant on ruby corpus', mutant: false do
  MutantSpec::Corpus::Project::ALL.select(&:mutation_generation).each do |project|
    specify "#{project.name} does not fail on mutation generation" do
      project.verify_mutation_generation
    end
  end

  MutantSpec::Corpus::Project::ALL.select(&:mutation_coverage).each do |project|
    specify "#{project.name} (#{project.integration}) does have expected mutation coverage" do
      project.verify_mutation_coverage
    end
  end
end
