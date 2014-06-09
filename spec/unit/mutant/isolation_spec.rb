require 'spec_helper'

describe Mutant::Isolation do
  describe '.isolate' do
    let(:object) { described_class }

    before do
      skip 'Series of events is indeterministic cross ruby implementations. Skipping this test under non 2.1.2' unless RUBY_VERSION.eql?('2.1.2')
    end

    let(:expected_return) { :foo }

    subject { object.call(&block) }

    def redirect_stderr
      $stderr = File.open('/dev/null')
    end

    unless ENV['COVERAGE']
      context 'when block returns mashallable data, and process exists zero' do
        let(:block) do
          lambda do
            :data_from_child_process
          end
        end

        it { should eql(:data_from_child_process) }
      end
    end

    context 'when block does return marshallable data' do
      let(:block) do
        lambda do
          redirect_stderr
          $stderr # not mashallable, nothing written to pipe and raises exception in child
        end
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(described_class::Error, 'Childprocess wrote un-unmarshallable data')
      end
    end

    context 'when block causes the child to exit nonzero' do
      let(:block) do
        lambda do
          method = Kernel.method(:exit!)
          Kernel.define_singleton_method(:exit!) do |_status|
            method.call(1)
          end
        end
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(described_class::Error, 'Childprocess exited with nonzero exit status: 1')
      end
    end
  end
end
