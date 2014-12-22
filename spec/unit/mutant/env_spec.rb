RSpec.describe Mutant::Env do
  let(:config) { Mutant::Config::DEFAULT.update(jobs: 1, reporter: Mutant::Reporter::Trace.new) }

  context '.new' do
    subject { described_class.new(config) }

    context 'when Module#name calls result in exceptions' do
      it 'warns via reporter' do
        klass = Class.new do
          def self.name
            fail
          end
        end

        expected_warnings = [
          "Class#name from: #{klass} raised an error: RuntimeError. #{Mutant::Env::SEMANTICS_MESSAGE}"
        ]

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

        expected_warnings = ["Class#name from: #{klass.inspect} returned Object. #{Mutant::Env::SEMANTICS_MESSAGE}"]

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

  context '#kill_mutation' do
    let(:object)   { described_class.new(config) }
    let(:result)   { double('Result')            }
    let(:mutation) { double('Mutation')          }

    subject { object.kill_mutation(mutation) }

    before do
      expect(mutation).to receive(:kill).with(config.isolation, config.integration).and_return(result)
    end

    it 'uses the configured integration and isolation to kill mutation' do
      should eql(Mutant::Result::Mutation.new(mutation: mutation, test_result: result))
    end
  end
end
