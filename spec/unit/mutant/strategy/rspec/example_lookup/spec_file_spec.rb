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

  context 'with bitwise xor method' do
    let(:method_name) { :^ }
    let(:expected_spec_file) { 'bitwise_xor_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with bitwise or method' do
    let(:method_name) { :| }
    let(:expected_spec_file) { 'bitwise_or_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with bitwise and method' do
    let(:method_name) { :& }
    let(:expected_spec_file) { 'bitwise_and_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with spaceship method' do
    let(:method_name) { :<=> }
    let(:expected_spec_file) { 'spaceship_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with case equality operator method' do
    let(:method_name) { :=== }
    let(:expected_spec_file) { 'case_equality_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with modulo operator method' do
    let(:method_name) { :% }
    let(:expected_spec_file) { 'modulo_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with exponentation operator method' do
    let(:method_name) { :** }
    let(:expected_spec_file) { 'exponentation_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with substraction operator method' do
    let(:method_name) { :- }
    let(:expected_spec_file) { 'substraction_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with addition operator method' do
    let(:method_name) { :+ }
    let(:expected_spec_file) { 'addition_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with greater than or equal to operator method' do
    let(:method_name) { :>= }
    let(:expected_spec_file) { 'greater_than_or_equal_to_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with less than or equal to operator method' do
    let(:method_name) { :<= }
    let(:expected_spec_file) { 'less_than_or_equal_to_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with greater than operator method' do
    let(:method_name) { :> }
    let(:expected_spec_file) { 'greater_than_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with less than operator method' do
    let(:method_name) { :< }
    let(:expected_spec_file) { 'less_than_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with right shift operator method' do
    let(:method_name) { :>> }
    let(:expected_spec_file) { 'right_shift_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with left shift operator method' do
    let(:method_name) { :<< }
    let(:expected_spec_file) { 'left_shift_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with division operator method' do
    let(:method_name) { :/ }
    let(:expected_spec_file) { 'division_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with multiplication operator method' do
    let(:method_name) { :* }
    let(:expected_spec_file) { 'multiplication_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with nomatch operator method' do
    let(:method_name) { :'!~' }
    let(:expected_spec_file) { 'nomatch_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with match operator method' do
    let(:method_name) { :=~ }
    let(:expected_spec_file) { 'match_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with inequality operator method' do
    let(:method_name) { :'!=' }
    let(:expected_spec_file) { 'inequality_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with equality operator method' do
    let(:method_name) { :== }
    let(:expected_spec_file) { 'equality_operator_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with element reader method' do
    let(:method_name) { :[] }
    let(:expected_spec_file) { 'element_reader_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with element writer method' do
    let(:method_name) { :[]= }

    let(:expected_spec_file) { 'element_writer_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with writer method' do
    let(:method_name) { :foo= }
    let(:expected_spec_file) { 'foo_writer_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with bang method' do
    let(:method_name) { :foo! }
    let(:expected_spec_file) { 'foo_bang_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with predicate method' do
    let(:method_name) { :foo? }
    let(:expected_spec_file) { 'foo_predicate_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end

  context 'with regular method' do
    let(:method_name) { :foo }
    let(:expected_spec_file) { 'foo_spec.rb' }

    it_should_behave_like 'Mutant::Strategy::Rspec::ExampleLookup#spec_file'
  end
end
