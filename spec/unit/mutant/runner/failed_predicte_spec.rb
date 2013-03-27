require 'spec_helper'

describe Mutant::Runner, '#failed?' do
  subject { object.failed? }

  let(:object) { class_under_test.run(config) }

  let(:config) { mock('Config') }
  let(:class_under_test) do
    success = self.success

    Class.new(described_class) do
      define_method :success? do
        success
      end

      define_method :run do
      end
    end
  end

  context 'when runner is successful' do
    let(:success) { true }

    it { should be(false) }
  end

  context 'when runner is NOT successful' do
    let(:success) { false }

    it { should be(true) }
  end
end
