# frozen_string_literal: true

RSpec.describe Mutant::AST::Meta::Optarg do
  subject(:object) { described_class.new(node) }

  let(:node)  { s(:optarg, name, value) }
  let(:name)  { :foo                    }
  let(:value) { s(:sym, :bar)           }

  its(:name) { should be(:foo) }
  its(:default_value) { should eql(s(:sym, :bar)) }

  describe '#used?' do
    subject { object.used? }

    it { should be true }

    context 'when name is prefixed with an underscore' do
      let(:name) { :_foo }
      it { should be false }
    end
  end

end
