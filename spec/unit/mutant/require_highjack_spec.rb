RSpec.describe Mutant::RequireHighjack do
  let(:highjacked_calls) { [] }
  let(:require_calls)    { [] }

  let(:target_module) do
    acc = require_calls
    Module.new do
      define_method(:require, &acc.method(:<<))

      module_function :require
      public :require
    end
  end

  def target_require(logical_name)
    Object.new.extend(target_module).require(logical_name)
  end

  describe '.call' do
    let(:logical_name) { double('Logical Name') }

    def apply
      described_class.call(target_module, highjacked_calls.method(:<<))
    end

    it 'returns the original implementation from singleton' do
      expect { apply.call(logical_name) }
        .to change { require_calls }
        .from([])
        .to([logical_name])
    end

    it 'does highjack target object #requires calls' do
      apply
      expect { target_require(logical_name) }
        .to change { highjacked_calls }
        .from([])
        .to([logical_name])
    end

    it 'does not call original require' do
      apply
      expect { target_require(logical_name) }
        .not_to change { require_calls }.from([])
    end
  end
end
