# encoding: utf-8

require 'spec_helper'

describe Mutant do
  describe '.singleton_subclass_instance' do
    let(:object) { described_class }

    subject { object.singleton_subclass_instance(name, superclass, &block) }

    before { subject }

    let(:name)       { 'Test'                }
    let(:block)      { proc { def foo; end } }
    let(:superclass) { Class.new             }

    let(:generated) { superclass.const_get(:Test) }

    it_should_behave_like 'a command method'

    it 'sets expected name' do
      name = generated.class.name
      expect(name).to eql("::#{self.name}")
      expect(name).to be_frozen
    end

    it 'stores instance of subclass' do
      expect(generated).to be_kind_of(superclass)
    end

    it 'evaluates the context of proc inside subclass' do
      expect(generated).to respond_to(:foo)
    end

    it 'generates nice #inspect' do
      inspect = generated.inspect
      expect(inspect).to eql("::#{self.name}")
      expect(inspect).to be_frozen
    end
  end

  describe '.isolate' do
    let(:object) { described_class }

    let(:expected_return) { :foo }

    subject { object.isolate(&block) }

    def redirect_stderr
      $stderr = File.open('/dev/null')
    end

    context 'when block returns mashallable data, and process exists zero' do
      let(:block) do
        lambda do
          :data_from_child_process
        end
      end

      it { should eql(:data_from_child_process) }
    end

    context 'when block does return marshallable data' do
      let(:block) do
        lambda do
          redirect_stderr
          $stderr # not mashallable, nothing written to pipe and raised exceptions in child
        end
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(Mutant::IsolationError, 'Childprocess wrote un-unmarshallable data')
      end
    end

    context 'when block does return marshallable data, but process exits with nonzero exitstatus' do
      let(:block) do
        lambda do
          redirect_stderr
          at_exit do
            raise
          end
          :foo
        end
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(Mutant::IsolationError, 'Childprocess exited with nonzero exit status: 1')
      end
    end
  end
end
