require 'spec_helper'

describe Mutant::Runner::Config, '#success?' do
  subject { object.success? }

  let(:object) { described_class.run(config) }

  let(:config)    { mock('Config', :strategy => strategy, :subjects => subjects) }
  let(:strategy)  { mock('Strategy')                                             }
  let(:subjects)  { [subject_a, subject_b]                                       }
  let(:subject_a) { mock('Subject A', :fails? => false)                          }
  let(:subject_b) { mock('Subject B', :fails? => false)                          }

  class DummySubjectRunner
    def initialize(_config, subject)
      @subject = subject
    end

    def failed?
      @subject.fails?
    end
  end

  before do
    stub_const('Mutant::Runner::Subject', DummySubjectRunner)
    strategy.stub(:setup)
    strategy.stub(:teardown)
  end

  context 'without failed subjects' do
    it { should be(true) }
  end

  context 'with failing subjects' do
    before do
      subject_a.stub(:fails? => true)
    end

    it { should be(false) }
  end
end
