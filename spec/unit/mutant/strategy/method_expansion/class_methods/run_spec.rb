require 'spec_helper'

describe Mutant::Strategy::MethodExpansion, '.run' do 
  subject { object.run(name) }

  let(:object) { described_class }

  context 'unexpandable and unmapped name' do
    let(:name) { :foo }

    it { should be(:foo) }
  end

  context 'expanded name' do

    context 'predicate' do
      let(:name) { :foo? }

      it { should be(:foo_predicate) }
    end

    context 'writer' do
      let(:name) { :foo= }

      it { should be(:foo_writer) }
    end

    context 'bang' do
      let(:name) { :foo! }

      it { should be(:foo_bang) }
    end

  end

  context 'operator expansions' do

    Mutant::OPERATOR_EXPANSIONS.each do |name, expansion|
      context "#{name}" do
        let(:name) { name }

        it "should expand to #{expansion}" do
          should be(expansion)
        end
      end
    end

  end
end
