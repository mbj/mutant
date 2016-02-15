RSpec.describe Mutant::RequireHighjack do
  let(:highjacked_calls) { [] }
  let(:require_calls)    { [] }

  let(:target_module) do
    acc = require_calls
    Module.new do
      define_method(:require, &acc.method(:<<))
      define_singleton_method(:require, &acc.method(:<<))
    end
  end

  def singleton_require(logical_name)
    target_module.require(logical_name)
  end

  def instance_require(logical_name)
    Object.new.extend(target_module).require(logical_name)
  end

  describe '.call' do
    let(:logical_name) { instance_double(String) }

    def apply
      described_class.call(target_module, highjacked_calls.method(:<<))
    end

    it 'prevents warnings' do
      expect(Mutant::WarningFilter.use(&method(:apply))).to eql([])
    end

    it 'returns the original implementation from singleton' do
      expect { apply.call(logical_name) }
        .to change { require_calls }
        .from([])
        .to([logical_name])
    end

    context '#require' do
      it 'does highjack calls' do
        apply
        expect { instance_require(logical_name) }
          .to change { highjacked_calls }
          .from([])
          .to([logical_name])
      end

      it 'does not call original require' do
        apply
        expect { instance_require(logical_name) }
          .not_to change { require_calls }.from([])
      end
    end

    context '.require' do
      it 'does highjack calls' do
        apply
        expect { singleton_require(logical_name) }
          .to change { highjacked_calls }
          .from([])
          .to([logical_name])
      end

      it 'does not call original require' do
        apply
        expect { singleton_require(logical_name) }
          .not_to change { require_calls }.from([])
      end
    end
  end
end
