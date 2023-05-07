# frozen_string_literal: true

RSpec.shared_examples 'frozen hook map' do |transform: nil|
  let(:map) do
    if transform
      apply.public_send(transform).map
    else
      apply.map
    end
  end

  it 'freezes map' do
    expect(map.frozen?).to be(true)
  end

  it 'freezes map values' do
    expect(map.values.all?(&:frozen?)).to be(true)
  end
end

RSpec.shared_context 'unknown hook name' do
  context 'unknown hook name' do
    let(:name) { :unknown_hook }

    it 'raises expected error' do
      expect { apply }.to raise_error(
        Mutant::Hooks::UnknownHook,
        'Unknown hook :unknown_hook'
      )
    end
  end
end

RSpec.describe Mutant::Hooks do
  let(:source) do
    <<~'RUBY'
      hooks.register(:mutation_insert_pre) do |mutation:|
        mutation << [__FILE__, __LINE__]
      end
    RUBY
  end

  describe '.assert_name' do
    def apply
      described_class.assert_name(name)
    end

    context 'on existing name' do
      let(:name) { :mutation_insert_pre }

      it 'returns self' do
        expect(apply).to be(described_class)
      end
    end

    include_context 'unknown hook name'
  end

  describe '.empty' do
    def apply
      described_class.empty
    end

    it 'returns empty hooks' do
      expect(apply).to eql(described_class::Builder.new.to_hooks)
    end

    include_examples 'frozen hook map'
  end

  describe '#merge' do
    def apply
      subject.merge(other)
    end

    let(:yields)  { [] }
    let(:block_a) { ->(_) { yields << :block_a } }
    let(:block_b) { ->(_) { yields << :block_b } }

    subject do
      builder = described_class::Builder.new
      builder.register(:mutation_insert_pre, &block_a)
      builder.to_hooks
    end

    let(:other) do
      builder = described_class::Builder.new
      builder.register(:mutation_insert_pre, &block_b)
      builder.to_hooks
    end

    it 'returns hooks equivalent to merged registration sequence' do
      apply.run(:mutation_insert_pre, foo: nil)

      expect(yields).to eql(%i[block_a block_b])
    end

    include_examples 'frozen hook map'
  end

  describe '#run' do
    let(:name)    { :mutation_insert_pre            }
    let(:payload) { instance_double('Some Payload') }

    subject do
      described_class.empty
    end

    def apply
      subject.run(name, foo: payload)
    end

    include_context 'unknown hook name'

    context 'on valid hook name' do
      context 'without registered hook' do
        it 'returns self' do
          expect(apply).to be(subject)
        end
      end

      context 'on registered hooks' do
        let(:yields) { [] }

        subject do
          builder = described_class::Builder.new

          builder.register(name, &yields.method(:<<))
          builder.register(name, &yields.method(:<<))

          builder.to_hooks
        end

        it 'calls registered block with payload' do
          expect { apply }
            .to change(yields, :to_a)
            .from([])
            .to([{ foo: payload }, { foo: payload }])
        end
      end
    end
  end

  describe '.load_pathname' do
    def apply
      described_class.load_pathname(pathname)
    end

    let(:pathname) do
      instance_double(
        Pathname,
        read: source,
        to_s: 'example.rb'
      )
    end

    it 'allows to capture hooks' do
      payload = []

      apply.run(:mutation_insert_pre, mutation: payload)

      expect(payload).to eql([['example.rb', 2]])
    end

    include_examples 'frozen hook map'
  end

  describe '.load_config' do
    def apply
      described_class.load_config(config)
    end

    let(:config) do
      Mutant::Config::DEFAULT.with(hooks: [hook_path_a, hook_path_b])
    end

    let(:hook_path_a) do
      instance_double(Pathname, read: source, to_s: 'example-a.rb')
    end

    let(:hook_path_b) do
      instance_double(Pathname, read: source, to_s: 'example-b.rb')
    end

    it 'loads hooks in sequence' do
      yields = []

      apply.run(:mutation_insert_pre, mutation: yields)

      expect(yields).to eql(
        [
          ['example-a.rb', 2],
          ['example-b.rb', 2]
        ]
      )
    end
  end
end

RSpec.describe Mutant::Hooks::Builder do
  subject { described_class.new }

  let(:block)  { ->(payload) { yields << payload } }
  let(:yields) { []                                }

  describe '#register' do
    def apply
      subject.register(name, &block)
    end

    context 'known hook name' do
      let(:name) { :mutation_insert_pre }

      it 'registers hook' do
        apply.to_hooks.run(name, foo: nil)

        expect(yields).to eql([{ foo: nil }])
      end

      it 'returns self' do
        expect(apply).to be(subject)
      end

      include_examples 'frozen hook map', transform: :to_hooks
    end

    include_context 'unknown hook name'
  end
end
