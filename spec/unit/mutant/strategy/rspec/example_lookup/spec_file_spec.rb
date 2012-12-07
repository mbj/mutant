require 'spec_helper'

describe Mutant::Strategy::Rspec::ExampleLookup, '#spec_file' do

  let(:object)           { described_class.new(mutation)                  }
  let(:mutation)         { mock('Mutation', :subject => mutation_subject) }
  let(:mutation_subject) { mock('Subject', :matcher => matcher)           }
  let(:matcher)          { mock('Matcher', :method_name => method_name)   }

  subject { object.send(:spec_file) }

  shared_examples_for 'Mutant::Strategy::Rspec::ExampleLookup#spec_file' do
    it_should_behave_like 'an idempotent method'

    it { should eql(expected_spec_file) }
    it { should be_frozen }
  end

  context 'with element reader method' do
    let(:method_name) { '[]' }
    let(:expected_spec_file) { 'element_reader_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with element writer method' do
    let(:method_name) { '[]=' }

    let(:expected_spec_file) { 'element_writer_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with writer method' do
    let(:method_name) { 'foo=' }
    let(:expected_spec_file) { 'foo_writer_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with bang method' do
    let(:method_name) { 'foo!' }
    let(:expected_spec_file) { 'foo_bang_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with predicate method' do
    let(:method_name) { 'foo?' }
    let(:expected_spec_file) { 'foo_predicate_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with regular method' do
    let(:method_name) { 'foo' }
    let(:expected_spec_file) { 'foo_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end
end
