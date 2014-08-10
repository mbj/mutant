RSpec.describe 'Mutant on ruby corpus' do

  before do
    skip 'Corpus test is deactivated on 1.9.3' if RUBY_VERSION.eql?('1.9.3')
    skip 'Corpus test is deactivated on RBX' if RUBY_ENGINE.eql?('rbx')
  end

  Corpus::Project::ALL.select(&:mutation_generation).each do |project|
    specify "#{project.name} does not fail on mutation generation" do
      project.verify_mutation_generation
    end
  end

  Corpus::Project::ALL.select(&:mutation_coverage).each do |project|
    specify "#{project.name} does have expected mutation coverage" do
      project.verify_mutation_coverage
    end
  end
end
