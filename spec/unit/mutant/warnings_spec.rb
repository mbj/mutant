# frozen_string_literal: true

RSpec.describe Mutant::Warnings do
  subject { described_class.new(warning_module) }

  before do
    subject # make sure we infect the module in any case
  end

  let(:original_messages) do
    []
  end

  let(:warning_module) do
    original_messages = original_messages()

    # Simulation of corelib `Warning` module
    Module.new do
      module_function def warn(*arguments)
        messages << arguments
      end

      module_function define_method(:messages) { original_messages }
    end
  end

  def cause_warnings
    original_messages.clear

    warning_module = warning_module()

    warning_module.warn('warning-a')

    Class
      .new { include warning_module }
      .new
      .instance_eval { warn('warning-b') }
  end

  describe '#call' do
    def apply
      subject.call { cause_warnings }
    end

    def expect_captured_messages(captured_messages)
      expect(captured_messages).to eql([%w[warning-a], %w[warning-b]])
      expect(captured_messages.frozen?).to eql(true)
      expect(captured_messages.map(&:frozen?)).to eql([true, true])
      expect(captured_messages.flat_map(&:frozen?)).to eql([true, true])
      expect(original_messages).to eql([])
    end

    def expect_original_messages
      expect(original_messages).to eql([%w[warning-a], %w[warning-b]])
    end

    it 'captures expected warnings during block execution' do
      expect_captured_messages(apply)
      expect(original_messages).to eql([])
    end

    it 'captures expected warnings during repeated block execution' do
      expect_captured_messages(apply)
      expect_captured_messages(apply)
    end

    it 'does use original implementation without block execution' do
      cause_warnings
      expect_original_messages
    end

    it 'does use original implementation before block execution' do
      cause_warnings
      expect_original_messages
      expect_captured_messages(apply)
    end

    it 'does use original implementation after block execution' do
      expect_captured_messages(apply)
      cause_warnings
      expect_original_messages
    end

    it 'rejects re-entrant use' do
      expect { subject.call { subject.call } }
        .to raise_error(described_class::RecursiveUseError)
    end
  end
end
