RSpec.describe Mutant::Env do
  let(:config) { Mutant::Config::DEFAULT.update(jobs: 1, reporter: Mutant::Reporter::Trace.new) }

  context '.new' do
    subject { described_class.new(config) }

    context 'when Module#name calls result in exceptions' do
      it 'warns via reporter' do
        klass = Class.new do
          def self.name
            raise
          end
        end

        expected_warnings = ["Class#name from: #{klass} raised an error: RuntimeError fix your lib to follow normal ruby semantics!"]

        expect { subject }.to change { config.reporter.warn_calls }.from([]).to(expected_warnings)

        # Fix Class#name so other specs do not see this one
        class << klass
          undef :name
          def name
          end
        end
      end
    end

    context 'when Module#name does not return a String or nil' do
      it 'warns via reporter' do
        klass = Class.new do
          def self.name
            Object
          end
        end

        expected_warnings = ["Class#name from: #{klass.inspect} returned #{Object.inspect} instead String or nil. Fix your lib to follow normal ruby semantics!"]

        expect { subject }.to change { config.reporter.warn_calls }.from([]).to(expected_warnings)

        # Fix Class#name so other specs do not see this one
        class << klass
          undef :name
          def name
          end
        end
      end
    end
  end
end
