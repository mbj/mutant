# frozen_string_literal: true

RSpec.describe Mutant::Parallel do
  describe '.async' do
    subject { described_class.async(config) }

    let(:config)  { instance_double(Mutant::Parallel::Config, env: env)       }
    let(:env)     { instance_double(Mutant::Actor::Env, new_mailbox: mailbox) }
    let(:mailbox) { Mutant::Actor::Mailbox.new                                }
    let(:master)  { instance_double(Mutant::Parallel::Master)                 }

    before do
      expect(described_class::Master).to receive(:call).with(config).and_return(master)
    end

    it { should eql(described_class::Driver.new(mailbox.bind(master))) }
  end
end
