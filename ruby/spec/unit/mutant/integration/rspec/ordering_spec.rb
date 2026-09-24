# frozen_string_literal: true

require 'mutant/integration/rspec'

RSpec.describe Mutant::Integration::Rspec::Ordering do
  let(:object) { described_class.new }

  let(:group_a) { class_double(RSpec::Core::ExampleGroup, 'group a') }
  let(:group_b) { class_double(RSpec::Core::ExampleGroup, 'group b') }

  let(:example_a) { mk_example(group_a, 'a') }
  let(:example_b) { mk_example(group_b, 'b') }
  let(:example_c) { mk_example(group_b, 'c') }

  def mk_example(group, id = "example-#{group.description}")
    instance_double(RSpec::Core::Example, id:).tap do |example|
      allow(example).to receive_messages(example_group: group)
    end
  end

  before do
    allow(group_a).to receive_messages(id: 'group-a', parent_groups: [group_a])
    allow(group_b).to receive_messages(id: 'group-b', parent_groups: [group_b])
  end

  describe '#call' do
    def apply
      object.call([example_c, example_a, example_b])
    end

    it 'returns self' do
      expect(apply).to be(object)
    end

    it 'ranks the examples in the given order' do
      apply

      expect(object.order([example_a, example_b, example_c]))
        .to eql([example_c, example_a, example_b])
    end

    it 'ranks a group by the best example it holds' do
      apply

      expect(object.order([group_a, group_b])).to eql([group_b, group_a])
    end

    it 'ranks every group above the example' do
      allow(group_b).to receive_messages(parent_groups: [group_b, group_a])

      apply

      expect(object.order([group_a, group_b])).to eql([group_a, group_b])
    end

    it 'forgets a previous ranking' do
      object.call([example_a, example_b])
      object.call([example_b])

      expect(object.order([example_a, example_b])).to eql([example_b, example_a])
    end
  end

  describe '#order' do
    def apply
      object.order(list)
    end

    context 'without a ranking' do
      let(:list) { [example_b, example_a] }

      it 'orders by rspec id' do
        expect(apply).to eql([example_a, example_b])
      end
    end

    context 'with a ranking contradicting the ids' do
      before do
        object.call([example_b])
      end

      let(:list) { [example_a, example_b] }

      it 'puts the ranked item first' do
        expect(apply).to eql([example_b, example_a])
      end
    end

    context 'with a ranking' do
      before do
        object.call([example_c, example_a])
      end

      context 'on an unranked item' do
        let(:list) { [example_b, example_a] }

        it 'sorts it last' do
          expect(apply).to eql([example_a, example_b])
        end
      end

      context 'on two unranked items' do
        let(:other) { mk_example(group_a, 'a-other') }
        let(:list)  { [example_b, other]             }

        it 'orders them by rspec id' do
          expect(apply).to eql([other, example_b])
        end
      end
    end
  end
end
