require 'spec_helper'

singleton = Mutant::Strategy::Rspec::DM2::Lookup::Method::Singleton

describe singleton, '#spec_files' do

  subject { object.spec_files }

  let(:object)           { described_class.new(mutation_subject) }
  let(:method_name)      { :bar                                  }
  let(:files)            { 'Files'.freeze                        }
  let(:context)          { double('Context', :name => 'Foo')     }

  let(:mutation_subject) do
    double(
      'Subject',
      :name => method_name,
      :public? => is_public,
      :context => context
    )
  end

  this_example_group = description

  shared_examples_for this_example_group do
    it_should_behave_like 'an idempotent method'

    before do
      if is_public
        Mutant::Strategy::MethodExpansion
          .should_receive(:run)
          .with(method_name)
          .and_return(:expanded_name)
      end
      Dir.should_receive(:glob)
        .with(expected_glob_expression)
        .and_return(files)
    end

    it { should be(files) }
    it { should be_frozen }
  end

  context 'with public method' do
    let(:is_public)                { true }

    let(:expected_glob_expression) do
      'spec/unit/foo/class_methods/expanded_name_spec.rb'
    end

    it_should_behave_like this_example_group
  end

  context 'with nonpublic method' do
    let(:is_public)                { false                                   }
    let(:expected_glob_expression) { 'spec/unit/foo/class_methods/*_spec.rb' }

    it_should_behave_like this_example_group
  end
end
