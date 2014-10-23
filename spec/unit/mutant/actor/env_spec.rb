RSpec.describe Mutant::Actor::Env do
  let(:mutex)       { double('Mutex')                           }
  let(:thread)      { double('Thread')                          }
  let(:thread_root) { double('Thread Root')                     }
  let(:actor)       { Mutant::Actor::Actor.new(thread, mailbox) }

  let(:object) { described_class.new(thread_root) }

  before do
    expect(Mutex).to receive(:new).and_return(mutex)
  end

  describe '#current' do
    subject { object.current }

    let!(:mailbox)    { Mutant::Actor::Mailbox.new                }

    before do
      expect(Mutant::Actor::Mailbox).to receive(:new).and_return(mailbox).ordered
      expect(thread_root).to receive(:current).and_return(thread)
    end

    it { should eql(actor) }
  end

  describe '#spawn' do
    subject { object.spawn(&block) }

    let!(:mailbox)    { Mutant::Actor::Mailbox.new                }

    let(:yields) { [] }

    let(:block) { ->(actor) { yields << actor } }

    before do
      expect(Mutant::Actor::Mailbox).to receive(:new).and_return(mailbox).ordered
      expect(thread_root).to receive(:new).and_yield.and_return(thread).ordered
      expect(thread_root).to receive(:current).and_return(thread).ordered
    end

    it 'returns sender' do
      should eql(actor.sender)
    end

    it 'yields actor' do
      expect { subject }.to change { yields }.from([]).to([actor])
    end
  end
end
