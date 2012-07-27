# This file is big. Once mutation interface does not change
# anymore it will be split up in mutation specific stuff.

require 'spec_helper'

shared_examples_for 'a mutation enumerator method' do
  it_should_behave_like 'a command method'


  context 'with no block' do
    subject { object.each }

    it { should be_instance_of(to_enum.class) }

    let(:expected_mutations)  do 
      mutations.map do |mutation|
        if mutation.respond_to?(:to_ast)
          mutation.to_ast.to_sexp
        else
          mutation
        end
      end.to_set
    end

    it 'generates the expected mutations' do
      subject = self.subject.map(&:to_sexp).to_set

      unless subject == expected_mutations
        message = "Missing mutations: %s\nUnexpected mutations: %s" %
         [expected_mutations - subject, subject - expected_mutations ].map(&:to_a).map(&:inspect)
        fail message
      end
    end
  end
end


describe Mutant::Mutator, '#each' do
  subject { object.each { |item| yields << item } }

  let(:yields)              { []                            }
  let(:object)              { class_under_test.new(node)    }
  let(:class_under_test)    { described_class.mutator(node) }
  let(:node)                { source.to_ast                 }
  let(:random_string)       { 'bar'                         }

  context 'true literal' do
    let(:source) { 'true' }

    let(:mutations) do
      %w(nil false)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'false literal' do
    let(:source) { 'false' }

    let(:mutations) do
      %w(nil true)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'symbol literal' do
    let(:source) { ':foo' }


    let(:mutations) do
      %w(nil) << ":#{random_string}"
    end

    before do
      Mutant.stub(:random_hex_string => random_string)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'string literal' do
    let(:source) { '"foo"' }

    let(:mutations) do
      %W(nil "#{random_string}")
    end

    before do
      Mutant.stub(:random_hex_string => random_string)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'fixnum literal' do
    let(:source) { '10' }

    let(:random_integer) { 5 }
    let(:mutations) do
      %W(nil 0 1 #{random_integer}) << [:lit, -10]
    end

    before do
      Mutant.stub(:random_fixnum => random_integer)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'float literal' do
    let(:source) { '10.0' }

    let(:mutations) do
      %W(nil 0.0 1.0 #{random_float} 0.0/0.0 1.0/0.0) << [:lit, -10.0]
    end
    
    let(:random_float) { 7.123 }

    before do
      Mutant.stub(:random_float => random_float)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'empty array literal' do
    let(:source) { '[]' }

    let(:mutations) do
      mutations = []

      # Literal replaced with nil
      mutations << [:nil]

      # Extra element
      mutations << '[nil]'
    end

    it_should_behave_like 'a mutation enumerator method'
  end


  context 'array literal' do
    let(:source) { '[true, false]' }

    let(:mutations) do
      mutations = []

      # Literal replaced with nil
      mutations << [:nil]
      
      # Mutation of each element in array
      mutations << '[nil, false]'
      mutations << '[false, false]'
      mutations << '[true, nil]'
      mutations << '[true, true]'

      # Remove each element of array once
      mutations << '[true]'
      mutations << '[false]'

      # Empty array
      mutations << '[]'

      # Extra element
      mutations << '[true, false, nil]'
    end
    
    it_should_behave_like 'a mutation enumerator method'
  end

  context 'hash literal' do
    let(:source) { '{true => true, false => false}' }

    let(:mutations) do
      mutations = []

      # Literal replaced with nil
      mutations << [:nil]

      # Mutation of each key and value in hash
      mutations << [:hash, [:false ], [:true ], [:false], [:false]]
      mutations << [:hash, [:nil   ], [:true ], [:false], [:false]]
      mutations << [:hash, [:true  ], [:false], [:false], [:false]]
      mutations << [:hash, [:true  ], [:nil  ], [:false], [:false]]
      mutations << [:hash, [:true  ], [:true ], [:true ], [:false]]
      mutations << [:hash, [:true  ], [:true ], [:nil  ], [:false]]
      mutations << [:hash, [:true  ], [:true ], [:false], [:true ]]
      mutations << [:hash, [:true  ], [:true ], [:false], [:nil  ]]

      # Remove each key once
      mutations << [:hash, [:true  ], [:true ]]
      mutations << [:hash, [:false ], [:false ]]

      # Empty hash
      mutations << [:hash]

      # Extra element
      mutations << [:hash, [:true  ], [:true ], [:false], [:false ], [:nil], [:nil] ]
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'block literal' do
    let(:source) { "true\nfalse" }

    let(:mutations) do
      mutations = []
      
      # Mutation of each statement in block
      mutations << "nil\nfalse"
      mutations << "false\nfalse"
      mutations << "true\nnil"
      mutations << "true\ntrue"

      # Remove statement in block
      mutations << [:block, [:true]]
      mutations << [:block, [:false]]
    end

    it_should_behave_like 'a mutation enumerator method'
  end
end
