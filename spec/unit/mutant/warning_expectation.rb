require 'spec_helper'

describe Mutant::WarningExpectation do
  let(:object) { described_class.new(expected_warnings) }

  let(:expected_warnings) { [] }
  let(:actual_warnings)   { [] }

  let(:warning_a) { "foo.rb:10: warning: We have a problem!\n" }
  let(:warning_b) { "bar.rb:10: warning: We have an other problem!\n" }

  describe '#execute' do
    subject { object.execute(&block) }

    before do
      @called = false
    end

    let(:block) do
      lambda do
        @called = true
        actual_warnings.each(&Kernel.method(:warn))
      end
    end

    it 'executes block' do
      expect { subject }.to change { @called }.from(false).to(true)
    end

    context 'when no warnings occur during block execution' do

      context 'and no warnings are expected' do
        it_should_behave_like 'a command method'
      end

      context 'and warnings are expected' do
        let(:expected_warnings) { [warning_a] }

        before do
          expect($stderr).to receive(:puts).with("Expected but missing warnings: #{[warning_a]}")
        end

        it_should_behave_like 'a command method'
      end
    end

    context 'when warnings occur during block execution' do
      let(:actual_warnings) { [warning_a, warning_b] }

      context 'and only some no warnings are expected' do
        let(:expected_warnings) { [warning_a] }

        it 'raises an expectation error' do
          expect { subject }.to raise_error(Mutant::WarningExpectation::ExpectationError.new([warning_b]))
        end
      end

      context 'and all warnings are expected' do
        let(:expected_warnings) { [warning_a, warning_b] }

        it_should_behave_like 'a command method'
      end

      context 'and there is an expected warning missing' do
        let(:expected_warnings) { [warning_a] }
        let(:actual_warnings)   { [warning_b] }

        it 'raises an expectation error' do
          expect { subject }.to raise_error(Mutant::WarningExpectation::ExpectationError.new([warning_b]))
        end
      end
    end
  end
end
