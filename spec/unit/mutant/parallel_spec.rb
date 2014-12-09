RSpec.describe Mutant::Parallel do
  describe '.async' do
    subject { described_class.async(config) }

    let(:config)  { double('Config', env: env)          }
    let(:env)     { double('ENV', new_mailbox: mailbox) }
    let(:mailbox) { Mutant::Actor::Mailbox.new          }
    let(:master)  { double('Master')                    }

    before do
      expect(described_class::Master).to receive(:call).with(config).and_return(master)
    end

    it { should eql(described_class::Driver.new(mailbox.bind(master))) }
  end
end
