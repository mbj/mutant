# frozen_string_literal: true

RSpec.describe Mutant::Result::Subject do
  let(:object) do
    described_class.new(
      subject:          mutation_subject,
      mutation_results: mutation_results,
      tests:            []
    )
  end

  let(:mutation_subject) do
    instance_double(
      Mutant::Subject,
      mutations: mutation_results.map { instance_double(Mutant::Mutation) }
    )
  end

  shared_context 'full coverage' do
    let(:mutation_results) do
      [
        instance_double(Mutant::Result::Mutation, success?: true)
      ]
    end
  end

  shared_context 'partial coverage' do
    let(:mutation_results) do
      [
        instance_double(Mutant::Result::Mutation, success?: false),
        instance_double(Mutant::Result::Mutation, success?: true)
      ]
    end
  end

  shared_context 'no coverage' do
    let(:mutation_results) do
      [
        instance_double(Mutant::Result::Mutation, success?: false)
      ]
    end
  end

  shared_context 'no results' do
    let(:mutation_results) { [] }
  end

  describe '#coverage' do
    subject { object.coverage }

    {
      'full coverage'    => 1r,
      'partial coverage' => 0.5r,
      'no coverage'      => 0r,
      'no results'       => 1r
    }.each do |name, expected|
      context(name) do
        include_context(name)
        it { should eql(expected) }
      end
    end
  end

  describe '#amount_mutations' do
    subject { object.amount_mutations }

    {
      'full coverage'    => 1,
      'partial coverage' => 2,
      'no coverage'      => 1,
      'no results'       => 0
    }.each do |name, expected|
      context(name) do
        include_context(name)
        it { should be(expected) }
      end
    end
  end

  describe '#amount_mutations_alive' do
    subject { object.amount_mutations_alive }

    {
      'full coverage'    => 0,
      'partial coverage' => 1,
      'no coverage'      => 1,
      'no results'       => 0
    }.each do |name, expected|
      context(name) do
        include_context(name)
        it { should be(expected) }
      end
    end
  end

  describe '#success?' do
    subject { object.success? }

    {
      'full coverage'    => true,
      'partial coverage' => false,
      'no coverage'      => false,
      'no results'       => true
    }.each do |name, expected|
      context(name) do
        include_context(name)
        it { should be(expected) }
      end
    end
  end
end
