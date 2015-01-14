RSpec.describe Mutant::RequireHighjack do
  let(:object) { described_class.new(target, highjacked_calls.method(:push)) }

  let(:highjacked_calls) { [] }
  let(:require_calls)    { [] }

  let(:target) do
    acc = require_calls
    Module.new do
      define_method(:require, &acc.method(:<<))
      module_function :require
    end
  end

  describe '#run' do
    let(:block)        { -> {}                  }
    let(:logical_name) { double('Logical Name') }

    subject do
      object.run(&block)
    end

    context 'require calls before run' do
      it 'does not highjack anything' do
        target.require(logical_name)
        expect(require_calls).to eql([logical_name])
        expect(highjacked_calls).to eql([])
      end
    end

    context 'require calls during run' do
      let(:block) { -> { target.require(logical_name) } }

      it 'does highjack the calls' do
        expect { subject }.to change { highjacked_calls }.from([]).to([logical_name])
        expect(require_calls).to eql([])
      end
    end

    context 'require calls after run' do

      it 'does not the calls anything' do
        subject
        target.require(logical_name)
        expect(require_calls).to eql([logical_name])
        expect(highjacked_calls).to eql([])
      end
    end
  end
end
