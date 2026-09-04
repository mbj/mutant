# frozen_string_literal: true

RSpec.describe Mutant::ContextMap do
  let(:root) { '/project' }

  let(:test_a) { '/project/spec/a_spec.rb:10' }
  let(:test_b) { '/project/spec/b_spec.rb:20' }

  let(:source) { '/project/lib/subject.rb' }

  let(:object) do
    described_class.new(
      root:,
      tables: {
        source => {
          # lines 1 and 3
          test_a => 0b101,
          # line 4
          test_b => 0b1000
        }
      }
    )
  end

  describe '.normalize' do
    def apply
      described_class.normalize(location, root)
    end

    context 'on a location relative to the recorded root' do
      let(:location) { 'spec/a_spec.rb:10' }

      it 'returns the absolute location' do
        expect(apply).to eql(test_a)
      end
    end

    context 'on a location relative to the framework working directory' do
      let(:location) { './spec/a_spec.rb:10' }

      it 'returns the absolute location' do
        expect(apply).to eql(test_a)
      end
    end

    context 'on an absolute location' do
      let(:location) { '/elsewhere/spec/a_spec.rb:10' }

      it 'returns the location unchanged' do
        expect(apply).to eql('/elsewhere/spec/a_spec.rb:10')
      end
    end

    context 'on a location without a line' do
      let(:location) { 'SomeClass#some_test' }

      it 'returns the location unchanged' do
        expect(apply).to eql('SomeClass#some_test')
      end
    end
  end

  describe '#normalize' do
    def apply
      object.normalize(location)
    end

    context 'on a location relative to the recorded root' do
      let(:location) { 'spec/a_spec.rb:10' }

      it 'resolves against the recording root' do
        expect(apply).to eql(test_a)
      end
    end

    context 'on a location without a line' do
      let(:location) { 'SomeClass#some_test' }

      it 'returns the location unchanged' do
        expect(apply).to eql('SomeClass#some_test')
      end
    end
  end

  describe '#reach' do
    def apply
      object.reach(path:, lines:)
    end

    let(:path) { Pathname.new(source) }

    context 'on lines one context covers' do
      let(:lines) { 3..3 }

      it 'counts the lines it executed' do
        expect(apply).to eql(test_a => 1)
      end
    end

    context 'on lines starting at the first' do
      let(:lines) { 1..1 }

      it 'counts from line one' do
        expect(apply).to eql(test_a => 1)
      end
    end

    context 'on lines ending before a covered one' do
      let(:lines) { 1..3 }

      it 'excludes the lines past the end' do
        expect(apply).to eql(test_a => 2)
      end
    end

    context 'on lines both contexts cover' do
      let(:lines) { 1..4 }

      it 'counts the lines each executed' do
        expect(apply).to eql(test_a => 2, test_b => 1)
      end
    end

    context 'on lines no context covers' do
      let(:lines) { 5..9 }

      it { expect(apply).to eql({}) }
    end

    context 'on a file the recording does not know' do
      let(:lines) { 1..4 }
      let(:path)  { Pathname.new('/project/elsewhere.rb') }

      it { expect(apply).to eql({}) }
    end

    context 'on a relative path' do
      let(:lines) { 3..3                           }
      let(:path)  { Pathname.new('lib/subject.rb') }

      let(:root)   { File.expand_path('.')              }
      let(:source) { File.expand_path('lib/subject.rb') }

      it 'resolves against the working directory' do
        expect(apply).to eql(test_a => 1)
      end
    end
  end

  describe '#footprint' do
    def apply
      object.footprint(context)
    end

    context 'on a recorded test' do
      let(:context) { test_a }

      it 'counts every line it executed' do
        expect(apply).to be(2)
      end
    end

    context 'on a test in several files' do
      let(:context) { test_b }

      let(:object) do
        super().with(
          tables: super().tables.merge('/project/lib/other.rb' => { test_b => 0b111 })
        )
      end

      it 'sums the lines across them' do
        expect(apply).to be(4)
      end
    end

    context 'on a test the recording does not name' do
      let(:context) { '/project/spec/absent_spec.rb:1' }

      it { expect(apply).to be(0) }
    end
  end

  describe '.popcount' do
    def apply
      described_class.popcount(value)
    end

    context 'on zero' do
      let(:value) { 0 }

      it { expect(apply).to be(0) }
    end

    context 'on a value with set bits' do
      let(:value) { 0b101101 }

      it { expect(apply).to be(4) }
    end
  end

  describe '#context_ids' do
    it 'returns every recorded test id' do
      expect(object.context_ids).to eql(Set[test_a, test_b])
    end
  end
end
