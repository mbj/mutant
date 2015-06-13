RSpec.describe Mutant::Zombifier do
  let(:root_require) { Pathname.new('project') }

  let(:pathname) do
    instance_double(::Pathname.singleton_class)
  end

  let(:require_highjack) do
    lambda do |block|
      original = ruby_vm.method(:require)
      allow(ruby_vm).to receive(:require, &block)
      original
    end
  end

  let(:options) do
    {
      load_path:        %w[a b],
      includes:         %w[project bar],
      namespace:        :Zombie,
      require_highjack: require_highjack,
      root_require:     root_require,
      pathname:         pathname,
      kernel:           ruby_vm
    }
  end

  let(:ruby_vm) do
    MutantSpec::RubyVM.new(
      [
        MutantSpec::RubyVM::EventExpectation::Require.new(
          expected_payload: {
            logical_name: 'project'
          }
        ),
        MutantSpec::RubyVM::EventExpectation::Eval.new(
          expected_payload: {
            binding:         TOPLEVEL_BINDING,
            source:          "module Zombie\n  module Project\n  end\nend",
            source_location: 'a/project.rb'
          },
          trigger_requires: %w[foo bar]
        ),
        MutantSpec::RubyVM::EventExpectation::Require.new(
          expected_payload: {
            logical_name: 'foo'
          },
          trigger_requires: %w[bar]
        ),
        MutantSpec::RubyVM::EventExpectation::Require.new(
          expected_payload: {
            logical_name: 'bar'
          }
        ),
        MutantSpec::RubyVM::EventExpectation::Eval.new(
          expected_payload: {
            binding:         TOPLEVEL_BINDING,
            source:          "module Zombie\n  module Bar\n  end\nend",
            source_location: 'b/bar.rb'
          },
          trigger_requires: %w[]
        ),
        MutantSpec::RubyVM::EventExpectation::Require.new(
          expected_payload: {
            logical_name: 'bar'
          }
        )
      ]
    )
  end

  let(:require_effects) do
    {
      'project' => { requires: [] }
    }
  end

  let(:file_entries) do
    {
      'a/project.rb' => { file: true, contents: 'module Project; end' },
      'b/bar.rb' =>     { file: true, contents: 'module Bar; end'     }
    }
  end

  let(:file_system) do
    MutantSpec::FileSystem.new(
      Hash[
        file_entries.map { |key, attributes| [key, MutantSpec::FileState.new(attributes)] }
      ]
    )
  end

  describe '.call' do
    def apply
      described_class.call(options)
    end

    before do
      allow(pathname).to receive(:new, &file_system.method(:path))
    end

    it 'returns self' do
      expect(apply).to be(described_class)
    end

    it 'consumes walks the VM through expected steps' do
      expect { apply }.to change { ruby_vm.done? }.from(false).to(true)
    end

    context 'when zombifier require fails' do
      let(:file_entries) do
        {}
      end

      it 'raises zombifier specific load error' do
        expect { apply }.to raise_error(described_class::LoadError, 'Cannot find file "project.rb" in load path')
      end
    end
  end
end
