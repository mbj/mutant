# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI, '.run' do
  subject { object.run(argv) }

  let(:object)     { described_class                              }
  let(:argv)       { double('ARGV')                               }
  let(:attributes) { double('Options')                            }
  let(:runner)     { double('Runner', success?: success)          }
  let(:config)     { double('Config')                             }
  let(:instance)   { double(described_class.name, config: config) }

  before do
    described_class.stub(new: instance)
    Mutant::Runner::Config.stub(run: runner)
  end

  context 'when runner is successful' do
    let(:success) { true }

    it { should be(0) }

    it 'should run with attributes' do
      Mutant::Runner::Config
        .should_receive(:run)
        .with(config)
        .and_return(runner)
      should be(0)
    end
  end

  context 'when runner fails' do
    let(:success) { false }

    it { should be(1) }

    it 'should run with attributes' do
      Mutant::Runner::Config
        .should_receive(:run)
        .with(config)
        .and_return(runner)
      should be(1)
    end
  end

end
