require 'spec_helper'

describe Mutant::Runner::Config, '#success?' do
  subject { object.success? }

  let(:object) { described_class.run(config) }

  let(:config) do
    double(
      'Config',
      :reporter => reporter,
      :strategy => strategy,
      :subjects => subjects
    )
  end

  let(:reporter)  { double('Reporter')                    }
  let(:strategy)  { double('Strategy')                    }
  let(:subjects)  { [subject_a, subject_b]                }
  let(:subject_a) { double('Subject A', :fails? => false) }
  let(:subject_b) { double('Subject B', :fails? => false) }

  class DummySubjectRunner
    include Concord::Public.new(:config, :subject)

    def self.run(*args)
      new(*args)
    end

    def failed?
      @subject.fails?
    end
  end

  before do
    stub_const('Mutant::Runner::Subject', DummySubjectRunner)
    reporter.stub(:report => reporter)
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
